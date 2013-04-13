WebSocketServer = require("ws").Server
fs = require("fs")
request = require("request")
NETCODES = require("./netcodes.js").NETCODES
MS = require("./message.js").MessageSerializer

class ClientHolder
  constructor: ->
    @clients = []

  addClient: (client) ->
    @clients.push(client) if client.ws? and client.uID? and client.authorized? is true

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

 class ChatClient
    constructor: (@ws, @clientHolder) ->
      @uID = undefined
      @authenticated = false

      @ws.on "message", @handleRequest

    authenticateConnection: (authObject) ->
      if validateAuthReq(authObject)
        @checkSession(authObject.SESSID)
      else
        @transmit {
          type: NETCODES.AUTH_RES,
          response: {
            value: false,
            reason: "AUTH_REQ INVALID"
          }
        }
        return false

    authenticateUser: (authObject) ->
      # Response from portaln indicates user is not logged in
      if authObject?.loggedin is not true
        @transmit {
          type: NETCODES.AUTH_RES,
          response: {
            value: false,
            reason: "SESSION INVALID"
          }
        }
        return false

      # Response from portaln carries no uID
      if not authObject?.uID
        @transmit {
          type: NETCODES.AUTH_RES,
          response: {
            value: false,
            reason: "NO LEGAL UID"
          }
        }
        ws.close(4027, "NO LEGAL UID")
        return false

      # Authorized client
      if authObject.loggedin is true
        @authorized = true
        @uID = authObject.uID

        @clientHolder.addClient(this)

        @transmit {
          type: NETCODES.AUTH_RES,
          response: {
            value: true,
            uID: authObject.uID
          }
        }

        logUserInfo("#{authObject.uID} connected.")
        return true
      return false

    checkSession: (sessid) ->
      checkObject = undefined

      request.post "http://latest.portaln.se/skola/chatapi.php", {form: {passwd: postPasswd, SESSID: sessid}}, (error, response, body) =>
        checkObject = JSON.parse(body) if response.statusCode is 200 and not error
        @authenticateUser(checkObject)

    handleRequest: (reqObject) =>
      parsedReq = MS.deserialize(reqObject)

      switch parsedReq.type
        when NETCODES.AUTH_REQ then @authenticateConnection(parsedReq)
        when NETCODES.MSG_SEND_REQ then handleMessageRequest(this, parsedReq.message)

      undefined

    transmit: (msgObject) ->
      try
        @ws.send(MS.serialize(msgObject))
        return null
      catch error
        return error

    transmitMessage: (msgObject) ->
      error = @transmit {
        type: NETCODES.MSG,
        message: msgObject
      }

      return error if error?

validateAuthReq = (authObject) ->
  return authObject?.type is NETCODES.AUTH_REQ and authObject?.SESSID

handleMessageRequest = (client, msgObject) ->
  clientFrom = ch.getClientByWS(client.ws)

  if not clientFrom?

    client.transmit {
      type: NETCODES.MSG_SEND_RES,
      response: {
        id: msgObject.id,
        value: false,
        reason: "not-connected"
      }
    }

  # Prevent uID spoofing
  msgObject.fromuID = clientFrom.uID

  clientTo = ch.getClientByuID(msgObject.touID)
  clientTo.transmitMessage(msgObject) if clientTo?

  client.transmit {
    type: NETCODES.MSG_SEND_RES,
    response: {
      id: msgObject.id,
      value: true
    }
  }

  logMessage(msgObject)

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
      written = true) for name in fileNames when fs.existsSync("#{logDir}#{name}") and not written

    fs.appendFileSync("#{logDir}#{fileNames[0]}", logString) unless written
  )


wssConfig = {port: 1337}
wss = new WebSocketServer(wssConfig)
ch = new ClientHolder()

postPasswd = "94bfd1921fe7663e776528e678e56f33"
logDir = "log/"

wss.on "connection", (ws) ->
  client = new ChatClient(ws, ch)

  ws.on "close", (code, reason) ->
    if ch.getClientByWS(ws)
      logUserInfo("#{ch.getClientByWS(ws).uID} disconnected.")
      ch.delClientByWS(ws)