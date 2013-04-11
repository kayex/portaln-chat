WebSocketServer = require("ws").Server
log = require("util").log
request = require("request")
NETCODES = require("./netcodes.js").NETCODES
MS = require("./message.js").MessageSerializer

postData = {
  passwd: "94bfd1921fe7663e776528e678e56f33",
  SESSID: undefined
}

class ClientHolder
  constructor: ->
    @clients = []

  addClient: (client) ->
    @clients.push(client)

  delClientByWS: (ws) ->
    @clients.splice(i,1) for client, i in @clients when client.ws is ws

  getClientByuID: (uID) ->
    return client for client in @clients when client.uID is uID

  getClientByWS: (ws) ->
    return client for client in @clients when client.ws is ws

  getClientCount: ->
    return @clients.length

createClient = (ws, uID) ->
  return {ws: ws, uID: uID}

checkSession = (sessID) ->
  checkResponse = ""
  request.post "http://latest.portaln.se/skola/chatapi.php/", {form: post}, (error, response, body) ->
    console.log("Body: #{body}")
    checkResponse = body if response.statusCode is 200 and not error

  checkObject = JSON.parse(checkResponse)

  return checkObject

authenticateConnection = (ws, authReq) ->
  authObject = JSON.parse(authReq)

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

  checkResponse = JSON.parse(checkSession(authObject.SESSID))

  # Response from portaln indicates user is not logged in
  if checkResponse?.loggedin is not true
    ws.send {
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
    ws.send {
      type: NETCODES.AUTH_RES,
      response: {
        value: false,
        reason: "NO LEGAL UID"
      }
    }
    ws.close(4027, "NO LEGAL UID")
    return false

  if checkResponse.loggedin is true
    ws.send {
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
    when NETCODES.MSG_SEND_REQ then handleMessageRequest(ws, parsedReq.msg)

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
  # Log message here

handleMessageRequest = (ws, msgObj) ->
  clientFrom = getClientByWS(ws)

  if not clientFrom?
    ws.send MS.serialize({
      type: NETCODES.MSG_SEND_RES,
      response: {
        id: msgObj.id,
        value: false,
        reason: "not-connected"
      }
      })

  clientTo = getClientByuID(msgObj.touID)

  transmitMessage(clientTo, msgObj) if clientTo?
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
    logUserInfo("#{ch.getClientByWS(ws).uID} disconnected.")
    ch.delClientByWS(ws)