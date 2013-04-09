WebSocketServer = require("ws").Server
log = require("util").log
MessageSerializer = require("./message.js").MessageSerializer

logMsg = (msg) ->
  log("> #{msg}")

logServerInfo = (info) ->
  log("# #{info}")

logUserInfo = (info) ->
  log("@ #{info}")

pushMessage = (messageObject) ->
  client.send(MessageSerializer.serialize(messageObject)) for client in clients
  logMsg(MessageSerializer.serialize(messageObject))

clearClient = (client) ->
  clients.splice(i,1) for cli, i in clients when cli is client

port = 1337

wss = new WebSocketServer {port: port}
clients = []
logServerInfo("Initated on port #{port}")

wss.on "connection", (ws) ->
  pushMessage({
    timeStamp: Date.now(),
    fromUser: "Server",
    toUser: "global",
    content: "@User connected!"
    })

  logUserInfo("User connected.")
  clients.push(ws)

  ws.on "message", (message) ->
    pushMessage(MessageSerializer.deserialize(message))

  ws.on "close", (code, message) ->
    clearClient(ws)
    pushMessage({
      timeStamp: Date.now(),
      fromUser: "Server",
      toUser: "global",
      content: "@User disconnected!"
      })

    logUserInfo("User disconnected.")