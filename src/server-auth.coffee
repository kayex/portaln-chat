WebSocketServer = require("ws").Server
fs = require("fs")
https = require("https")
request = require("request")
MS = require("./message.js").Message

class ChatClientConnection
  constructor: (@ws, @callback) ->
    @uID = undefined
    @authenticated = false
    @callbacks = {
      "message": undefined,
      "close": undefined
    }

    @ws.on "message", (message) =>
      @emit("message", message)

    @ws.on "close", (code, reason) =>
      @emit("close")

  emit: (event, arg) ->
    callback(arg) for evt, callback of @callbacks when evt is event and typeof callback is "function"

  on: (event, callback) ->
    do(=>
      @callbacks[event] = callback
    ) if typeof event is "string" and typeof callback is "function"

  transmit: (msgObject) ->
    try
      @ws.send(MS.serialize(msgObject))
      return null
    catch error
      return error

class ChatServer
  constructor: (@config) ->
    config = {
      key: fs.readFileSync("../keys/key.pem"),
      cert: fs.readFileSync("../keys/cert.pem")
    }
    server = https.createServer(config)
    server.listen(1337)

    @wss = new WebSocketServer({server: server})
    @clients = []

    @callbacks = {
      "client connect": undefined,
      "client disconnect": undefined,
      "message": undefined,
    }

    @wss.on "connection", (ws) =>
      client = new ChatClientConnection(ws)
      client.on "message", (message) =>
        @handleClientRequest(client, MS.deserialize(message))

      client.on "close", =>
        id = "unauthorized"
        registeredClient = @getClientByWS(client.ws)

        if registeredClient?
          id = registeredClient.uID
          @delClientByWS(client.ws)
        @emit("client disconnect", id)

  emit: (event, arg) ->
    callback(arg) for evt, callback of @callbacks when evt is event and typeof callback is "function"

  on: (event, callback) ->
    do(=>
      @callbacks[event] = callback
    ) if typeof event is "string" and typeof callback is "function"

  handleClientRequest: (client, request) =>
    switch MS.typeOf(request)
      when MS.CODES.AUTH_REQ
        @checkSession(client, request.SESSID, @authenticateUser)
      when MS.CODES.MSG_SEND_REQ
        @handleClientMessageRequest(client, request.message)

  handleClientMessageRequest: (client, message) ->
    clientFrom = @getClientByWS(client.ws)

    unless clientFrom?
      client.transmit MS.createMsgSendRes(false, {id: message?.id, reason:"NOT CONNECTED"})
      return false

    # Prevent uID spoofing
    message.fromuID = clientFrom.uID

    clientTo = @getClientByuID(message.touID)
    clientTo.transmit MS.createMsg(message) if clientTo?
    clientFrom.transmit (MS.createMsgSendRes(true, {id: message?.id}))

    @emit("message", message)

  authenticateUser: (client, authObject, done) =>
    # Response from portaln.se is invalid
    unless MS.assert(authObject, MS.CODES.AUTH_EXTERNAL_RES)
      client.transmit MS.createAuthRes(false, {reason: "AUTHENTICATION FAILED"})
      return false

    if authObject.loggedin
      client.transmit MS.createAuthRes(true, {uID: authObject.uID})
      client.authorized = true
      client.uID = authObject.uID
      @addClient(client)
      @emit("client connect", client.uID)
      return true

    else
      client.transmit MS.createAuthRes(false, {reason: "INVALID SESSID"})
      return false

  checkSession: (client, sessid, callback) =>
    request.post "http://latest.portaln.se/skola/chatapi/authSESSID.php", {form: {passwd: @config.authKey, SESSID: sessid}}, (error, response, body) =>
      checkObject = JSON.parse(body) if response.statusCode is 200 and not error
      callback(client, checkObject)

  addClient: (client) ->
    @clients.push(client) if client.ws? and client.uID? and client.authorized

  delClientByWS: (ws) ->
    @clients.splice(i,1) for client, i in @clients when client?.ws is ws

  getClientByuID: (uID) ->
    return client for client in @clients when client?.uID is uID
    return null

  getClientByWS: (ws) ->
    return client for client in @clients when client?.ws is ws
    return null

  getClientCount: ->
    return @clients.length

logWithTime = (txt) ->
  return "\n[#{Date.now()}] #{txt}"

logUserInfo = (info) ->
  logString = logWithTime("@#{info}")
  fs.appendFile "#{logDir}activity.log", logString, (err) ->
    console.log("Error writing activity.log") if err

logServerInfo = (info) ->
  logString = logWithTime("##{info}")
  fs.appendFile "#{logDir}server.log", logString, (err) ->
    console.log("Error writing server.log") if err

logMessage = (msgObject, callback) ->
  process.nextTick(->
    logDir = "log/"
    logString = "\n[#{msgObject.timeStamp}] #{msgObject.fromuID}->#{msgObject.touID} #{msgObject.content}"
    fileNames = ["#{msgObject.fromuID}-#{msgObject.touID}.log", "#{msgObject.touID}-#{msgObject.fromuID}.log"]
    written = false

    do(->
      fs.appendFileSync("#{logDir}#{name}", logString)
      written = true) for name in fileNames when fs.existsSync("#{logDir}#{name}") unless written

    fs.appendFileSync("#{logDir}#{fileNames[0]}", logString) unless written
  )

config = {authKey: "94bfd1921fe7663e776528e678e56f33"}
cs = new ChatServer(config)

cs.on "message", logMessage
cs.on "client connect", logUserInfo
cs.on "client disconnect", logUserInfo

logDir = "log/"