WebSocketServer = require("ws").Server
log = require("util").log
NETCODES = require("./netcodes.js").NETCODES

class ClientHolder
  constructor: ->
    @clients = []

  addClient: (client) ->
    @clients.push(client)

  delClientByWS: (ws) ->
    @clients.splice(i,1) for client, i in @clients when client.ws is ws

  getClientByuID: (uID) ->
    return client for client in @clients when client.uID is uID

  getClientCount: ->
    return @clients.length

createClient = (ws, uID) ->
  return {ws: ws, uID: uID}

checkSession = (sessID) ->
  # Post to portaln.se here

authenticateConnection = (ws, authReq) ->
  authObject = JSON.parse(authReq)
  if authObject.?type is not NETCODES.AUTH_REQ or not authObject.?SESSID
    ws.close(4025, "Invalid AUTH_REQ")
    return false

  checkResponse = JSON.parse(checkSession(authObject.SESSID))

  if checkResponse?.loggedin is not true
    ws.close(4026, "Session invalid")
    return false

  if not checkResponse?.uID
    ws.close(4027, "uID invalid")
    return false

  ch.addClient(createClient(ws, checkResponse.uID))
  return true

parseMessage = (msg) ->
  # Handle message requests


wssConfig = {port: 1337}
wss = new WebSocketServer(wssConfig)

ch = new ClientHolder()

wss.on "connection", (ws) ->
  ws.on "message", (msg) ->
    if authenticateConnection(ws, msg) is true
      ws.on "message", (msg) ->
        parseMessage(msg)

