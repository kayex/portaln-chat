dh = undefined
ws = undefined
window.activeUser = "User_0123"
MessageSerializer = window.MessageSerializer

config = {server: "ws://arch.jvester.se:1337"}

init = ->
  dh = new window.DOMHandle()
  dh.initDOMChange()

  dh.chatTextarea.attr("placeholder", "Enter your desired username.")

  dh.on "submit", (text) ->
    window.activeUser = text.content
    dh.chatTextarea.attr("placeholder", "Enter your message here.")

    dh.on "submit", (text) ->
      sendMessage {
        timeStamp: Date.now(),
        fromUser: window.activeUser,
        toUser: "global",
        content: text.content
      }

  connect(config)

sendMessage = (messageObject) ->
  ws.send(MessageSerializer.serialize(messageObject))

displayInfo = (info) ->
  dh.chatStatus.html(info)

connect = (config) ->
  ws = new WebSocket(config.server)
  dh.chatStatus.html("Connecting...")

  ws.onopen = ->
    displayInfo "Connection established to #{ws.url}"
    displayInfo "Connection status: #{ws.readyState}"

  ws.onmessage = (message) ->
    dh.addMessageToPage(MessageSerializer.deserialize(message.data))

init()