MS = window.Message

class ChatClient
  constructor: (server, @sessid) ->
    @ws = new WebSocket(server)
    @uID = undefined
    @authenticated = false
    @msgID = 10

    @callbacks = {
      "cstatus": undefined,
      "message": undefined,
      "confirmation": undefined
    }

    @ws.onmessage = (message) =>
      @handleIncoming(MS.deserialize(message.data))
    @ws.onopen = =>
      @emit("cstatus", "Connected to IM Server.")
      @sendAuthChallenge()

  handleIncoming: (incObject) =>
    switch MS.typeOf(incObject)
      when MS.CODES.AUTH_RES then @authenticate(incObject)
      when MS.CODES.MSG_SEND_RES then @emit("confirmation", incObject.response)
      when MS.CODES.MSG then @emit("message", incObject.message)

    undefined

  transmit: (msgObject) ->
    try
      @ws.send(MS.serialize(msgObject))
      return null
    catch error
      return error

  transmitMessage: (msgObject) ->
    error = @transmit MS.createMsgSendReq(msgObject)
    return error if error?

  createMessageWithID: (msgObject) ->
    # add ID to message (to confirm its delivery with MSG_SEND_RES)
    msgObject.id = @msgID
    @msgID++
    return msgObject

  emit: (event, arg) ->
    callback(arg) for evt, callback of @callbacks when evt is event and typeof callback is "function"

  on: (event, callback) ->
    do(=>
      @callbacks[event] = callback
    ) if typeof event is "string" and typeof callback is "function"

  authenticate: (authObject) ->
    unless MS.assert(authObject, MS.CODES.AUTH_RES)
      @emit("cstatus", "AUTH_RES INVALID")
      @authenticated = false
      return false

    if authObject.response.value
      @uID = authObject.response.uID
      @emit("cstatus", "Client verified.")
      @authenticated = true
      return true
    else
      @emit("cstatus", "Client denied.")
      @authenticated = false
      return false

  sendAuthChallenge: ->
    @emit("cstatus", "Authorizing...")
    @transmit MS.createAuthReq(@sessid)

window.ChatClient = ChatClient