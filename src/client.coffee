dh = undefined
ws = undefined
activeUser = undefined
message = require(message)

init = ->
  dh = new window.DOMHandle()
  dh.initDOMChange()



  activeUser = "User_01"

  dh.on "submit", (text) ->
    sendMessage {
      timeStamp: Date.now(),
      fromUser: activeUser,
      toUser: "global",
      content: text.content
    }

  connect()

sendMessage = (messageObject) ->
  ws.send(compileMessage(messageObject))

displayInfo = (info) ->
  dh.chatStatus.html(info)

compileMessage = (messageObject) ->
  timeStamp = messageObject.timeStamp
  toUser = messageObject.toUser
  fromUser = messageObject.fromUser
  # Prevent pre-mature delimiter injection
  content = messageObject.content.replace("|", "")
  compiledMessage = "#{timeStamp}|#{toUser}|#{fromUser}|#{content}"

decompileMessage = (message) ->
  split = message.data.split("|")
  messageObject = {
    timeStamp: split[0],
    toUser: split[1],
    fromUser: split[2],
    content: split[3]
  }

connect = ->
  ws = new WebSocket("ws://arch.jvester.se:1337")
  dh.chatStatus.html("Connecting...")

  ws.onopen = ->
    displayInfo "Connection established to #{ws.url}"
    displayInfo "Connection status: #{ws.readyState}"

  ws.onmessage = (message) ->
    dh.addMessageToPage(decompileMessage(message))

init()