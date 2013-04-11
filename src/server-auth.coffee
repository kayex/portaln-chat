WebSocketServer = require("ws").Server
log = require("util").log
request = require("request")
NETCODES = require("./netcodes.js").NETCODES
MS = require("./message.js").MessageSerializer

postPasswd = "94bfd1921fe7663e776528e678e56f33"

class ClientHolder
  constructor: ->
    @clients = []

  addClient: (client) ->
    @clients.push(client)

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

createClient = (ws, uID) ->
  return {ws: ws, uID: uID}

checkSession = (sessID) ->
  a = 0
  checkObject = undefined

  # checkObject = {
  #   loggedin: true,
  #   uID: "12345"
  # }

  request.post "http://latest.portaln.se/skola/chatapi.php", {form: {passwd: postPasswd, SESSID: sessID}}, (error, response, body) ->
    console.log("Error #{error}")
    console.log("Response #{response}")
    console.log("Body: #{body}")
    checkObject = JSON.parse(body) if response.statusCode is 200 and not error

  a = 0 until checkObject?
  return checkObject

authenticateConnection = (ws, authReq) ->
  console.log("Authenticating connection")
  authObject = JSON.parse(authReq)
  console.log(authObject)

  # Invalid AUTH_REQ
  if authObject?.type is not NETCODES.AUTH_REQ or not authObject?.SESSID
    ws.send {
      type: NETCODES.AUTH_RES,
      response: {
        value: false,
        reason: "AUTH_REQ INVALID"
      }
    }
    ws.close(4025, "AUTH_REQ INVALID")
    return false

  checkResponse = checkSession(authObject.SESSID)

  # Response from portaln indicates user is not logged in
  if checkResponse?.loggedin is not true
    ws.send MS.serialize {
      type: NETCODES.AUTH_RES,
      response: {
        value: false,
        reason: "SESSION INVALID"
      }
    }
    ws.close(4026, "Session invalid")
    return false

  # Response from portaln carries no uID
  if not checkResponse?.uID
    ws.send MS.serialize {
      type: NETCODES.AUTH_RES,
      response: {
        value: false,
        reason: "NO LEGAL UID"
      }
    }
    ws.close(4027, "NO LEGAL UID")
    return false

  if checkResponse.loggedin is true
    ws.send MS.serialize {
      type: NETCODES.AUTH_RES,
      response: {
        value: true,
        uID: checkResponse.uID
      }
    }

    # Return authorized client
    return createClient(ws, checkResponse.uID)

  return false

handleRequest = (ws, req) ->
  parsedReq = MS.deserialize(req)

  switch parsedReq.type
    when NETCODES.MSG_SEND_REQ then handleMessageRequest(ws, parsedReq.message)

createMessageForWire = (msgObj) ->
  message = {
    type: NETCODES.MSG,
    message: msgObj
  }

  return message

transmitMessage = (ws, msgObj) ->
  ws.send(MS.serialize(createMessageForWire(msgObj)))

logUserInfo = (info) ->
  log("@ #{info}")

logServerInfo = (info) ->
  log("# #{info}")

logMessage = (msgObj) ->
  log("> #{msgObj.fromuID} -> #{msgObj.touID}: #{msgObj.content}")

logMessageToDisk = (msgObj) ->
  console.log("Message to disk")
  # Log message here

handleMessageRequest = (ws, msgObj) ->
  console.log("Handling message request")
  clientFrom = ch.getClientByWS(ws)

  if not clientFrom?
    console("this client is not registered")
    ws.send MS.serialize({
      type: NETCODES.MSG_SEND_RES,
      response: {
        id: msgObj.id,
        value: false,
        reason: "not-connected"
      }
      })

  console.log("fromClient is logged in!")

  clientTo = ch.getClientByuID(msgObj.touID)

  transmitMessage(clientTo.ws, msgObj) if clientTo?

  console.log("Sending response")

  ws.send MS.serialize({
    type: NETCODES.MSG_SEND_RES,
    response: {
      id: msgObj.id,
      value: true
    }
    })

  logMessage(msgObj)
  logMessageToDisk(msgObj)

wssConfig = {port: 1337}
wss = new WebSocketServer(wssConfig)
ch = new ClientHolder()

wss.on "connection", (ws) ->
  ws.on "message", (msg) ->
    authClient = authenticateConnection(ws, msg)
    if authClient?
      ch.addClient(authClient)
    else
      return

    ws.on "message", (msg) ->
      handleRequest(ws, msg)

  ws.on "close", (code, reason) ->
    if ch.getClientByWS(ws)
      logUserInfo("#{ch.getClientByWS(ws).uID} disconnected.")
      ch.delClientByWS(ws)