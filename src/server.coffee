WebSocketServer = require("ws").Server
log = require("util").log

logMsg = (msg) ->
  log("> #{msg}")

logInfo = (info) ->
  log("# #{info}")

port = 1337

wss = new WebSocketServer {port: port}
clients = []

logInfo("Initated on port #{port}")

wss.on "connection", (ws) ->
  clients.push(ws)

  ws.on "message", (message) ->
    logMsg(message)
    client.send(message) for client in clients

  ws.on "close", (code, message) ->
    clients.splice(i,1) for client, i in clients when client is ws