dh = undefined
ws = undefined
lastMessageTime = 0
lastMessageContent = ""
window.activeUser = "User_0123"
MS = window.MessageSerializer

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

      lastMessageTime = Date.now()
      lastMessageContent = text.content

  connect(config)

sendMessage = (messageObject) ->
  ws.send(MS.serialize(messageObject))

displayInfo = (info) ->
  dh.chatStatus.html(info)

connect = (config) ->
  ws = new WebSocket(config.server)
  dh.chatStatus.html("Connecting...")

  ws.onopen = ->
    displayInfo "Connection established to #{ws.url}"
    displayInfo "Connection status: #{ws.readyState}"

  ws.onmessage = (message) ->
    console.log("Roundtrip: #{Date.now() - lastMessageTime} ms - '#{MS.deserialize(message.data).content}'") if MS.deserialize(message.data).content is lastMessageContent
    dh.addMessageToPage(MS.deserialize(message.data))

init()