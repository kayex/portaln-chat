WebSocketServer = require("ws").Server
log = require("util").log
message = require("message")

logMsg = (msg) ->
  log("> #{msg}")

logServerInfo = (info) ->
  log("# #{info}")

logUserInfo = (info) ->
  log("@ #{info}")

port = 1337

wss = new WebSocketServer {port: port}
clients = []
logServerInfo("Initated on port #{port}")

wss.on "connection", (ws) ->
  logUserInfo("User connected.")
  clients.push(ws)

  ws.on "message", (message) ->
    logMsg(message)
    client.send(message) for client in clients

  ws.on "close", (code, message) ->
    clients.splice(i,1) for client, i in clients when client is ws