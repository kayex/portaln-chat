class MessageSerializer
  @serialize: (messageObject) ->
    timeStamp = messageObject.timeStamp
    toUser = messageObject.toUser
    fromUser = messageObject.fromUser
    # Prevent pre-mature delimiter injection
    content = messageObject.content.replace("|", "")
    serialized = "#{timeStamp}|#{toUser}|#{fromUser}|#{content}"

  @deserialize: (message) ->
    split = message.split("|")
    messageObject = {
      timeStamp: split[0],
      toUser: split[1],
      fromUser: split[2],
      content: split[3]
    }

if not window?
  module.exports = exports
  exports.MessageSerializer = MessageSerializer
else
  window.MessageSerializer = MessageSerializer