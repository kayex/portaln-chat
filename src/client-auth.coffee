MS = window.MessageSerializer
NETCODES = window.NETCODES

class ChatClient
  constructor: (server, @sessid) ->
    @ws = new WebSocket(server)
    @uID = undefined
    @authenticated = false
    @msgID = 10

    @callbacks = {
      "cstatus": undefined,
      "message": undefined,
      "confirmed": undefined
    }

    @ws.onmessage = (message) => @handleIncoming(message)
    @ws.onopen = =>
      @emit("cstatus", "Connected to IM Server.")
      @sendAuthChallenge()

  handleIncoming: (incObject) =>
    parsedInc = MS.deserialize(incObject.data)

    switch parsedInc.type
      when NETCODES.AUTH_RES then @authenticate(parsedInc)
      when NETCODES.MSG_SEND_RES then @emit("confirmed", parsedInc)
      when NETCODES.MSG then @emit("message", parsedInc.message)

    undefined

  transmit: (msgObject) ->
    try
      @ws.send(MS.serialize(msgObject))
      return null
    catch error
      return error

  transmitMessage: (msgObject) ->
    error = @transmit {
      type: NETCODES.MSG_SEND_REQ,
      message: msgObject
    }

    return error if error?

  createMessage: (msgObject) ->
    msgObject.id = @msgID
    @msgID++

  emit: (event, arg) ->
    callback(arg) for evt, callback of @callbacks when evt is event and callback?

  on: (event, callback) ->
    @callbacks[event] = callback

  authenticate: (authObject) ->
    if authObject?.type is not NETCODES.AUTH_RES or not authObject?.response?.value?
      logConnectionInfo("AUTH_RES INVALID")
      @authenticated = false
      return false

    if authObject.response.value is true
      @uID = authObject.response.uID
      logConnectionInfo("Client verified.")
      @authenticated = true
      return true
    else
      logConnectionInfo("Client denied.")
      @authenticated = false
      return false

  sendAuthChallenge: ->
    @emit("cstatus", "Authorizing...")
    @transmit {
      type: NETCODES.AUTH_REQ,
      SESSID: @sessid
    }

logConnectionInfo = (info) ->
  console.log(info)

chatServer = "ws://arch.jvester.se:1337"

SESSID = window.getCookie("PORTALNSESSID")

cc = new ChatClient(chatServer, SESSID)
cc.on "cstatus", (status) ->
  console.log(status)
cc.on "message", (msgObject) ->
  console.log(msgObject)

window.cc = cc