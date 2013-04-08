root = this

root.message = root.message or {}

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