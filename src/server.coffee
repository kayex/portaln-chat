WebSocketServer = require("ws").Server
port = 1337

wss = new WebSocketServer {port: port}
clients = []
console.log "Listening on port #{port}"

wss.on "connection", (ws) ->
  clients.push(ws)

  ws.on "message", (message) ->
    console.log(message)
    client.send(message) for client in clients

  ws.on "close", (code, message) ->
    clients.splice(i,1) for client, i in clients when client is ws