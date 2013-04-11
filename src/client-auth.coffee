MS = window.MessageSerializer
NETCODES = window.NETCODES
dh = window.Domhandle

class ChatConnection
  constructor: (@server, @sessid) ->
    @ws = undefined
    @authenticated = false
    @msgID = 10
    @uID = ""
    @callbacks = {
      "message": undefined
    }

  connect: ->
    @ws = new WebSocket(@server)
    @ws.onopen = =>
      @authenticate()
    undefined

  handleMessage: (msg) ->
    console.log(msg)
    console.log(msg.data)
    parsedMsg = MS.deserialize(msg.data)
    @emit("message", parsedMsg)

  emit: (event, arg) ->
    callback(arg) for evt, callback of @callbacks when evt is event

  on: (event, callback) ->
    @callbacks[event] = callback

  sendMessage: (msgObj) ->
    msgObj.id = @msgID
    @msgID++
    @ws.send(MS.serialize(createMsgRequest(msgObj)))

  authenticate: ->
    @ws.onmessage = (msg) =>
      console.log("Message: #{msg.data}")
      authObject = MS.deserialize(msg.data)

      if authObject?.type is not NETCODES.AUTH_RES or not authObject?.response?.value or not authObject?.response?.uID
        logConnectionInfo("AUTH_RES INVALID")
        @authenticated = false

      if authObject.response.value is true
        @uID = authObject.response.uID
        logConnectionInfo("Client verified.")
        @authenticated = true

        @ws.onmessage = @handleMessage

    @ws.send MS.serialize({
      type: NETCODES.AUTH_REQ,
      SESSID: @sessid
    })

    console.log(MS.serialize({type: NETCODES.AUTH_REQ, SESSID: @sessid}))

logConnectionInfo = (info) ->
  console.log(info)

createMsgRequest = (msgObj) ->
  request = {
    type: NETCODES.MSG_SEND_REQ,
    message: msgObj
    }

  return request

chatServer = "ws://127.0.0.1:1337"

SESSID = window.getCookie("PORTALNSESSID")

cc = new ChatConnection(chatServer, SESSID)
cc.connect()
cc.on "message", (msgObject) ->
  console.log(msgObject)

window.cc = cc