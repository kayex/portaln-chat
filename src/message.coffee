class MessageSerializer
  @serialize: (messageObject) ->
    return JSON.stringify(messageObject)

  @deserialize: (message) ->
    return JSON.parse(message)

if not window?
  module.exports = exports
  exports.MessageSerializer = MessageSerializer
else
  window.MessageSerializer = MessageSerializer