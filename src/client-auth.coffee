MS = window.MessageSerializer
NETCODES = window.NETCODES
dh = window.Domhandle

class ChatConnection
  constructor: (@ws) ->
    @wsReady = false
    @authenticated = false
    @msgID = 10
    @uID = ""
    @callbacks = {
      "message": undefined
    }
    @ws.onopen = =>
      console.log("onopen")
      @wsReady = true

  handleMessage: (msg) ->
    parsedMsg = MS.deserialize(msg.content)
    emit("message", parsedMsg)

  emit: (event, arg) ->
    callback(arg) for evt, callback of @callbacks when evt is event

  on: (event, callback) ->
    @callbacks[event] = callback

  sendMessage: (msgObj) ->
    msgObj.id = @msgID
    @msgID++
    @ws.send(MS.serialize(createMsgRequest(msgObj)))

  sendAuthentication: (sessid) ->
    console.log("send auth")
    console.log(sessid)
    if @wsReady
      console.log("Ws ready")
      @ws.send {
        type: NETCODES.AUTH_REQ,
        SESSID: sessid
      }

  authenticate: (sessid) ->
    @ws.onmessage = (msg) ->
      console.log("Message: #{msg}")
      authObject = MS.deserialize(msg.content)

      if authObject?.type is not NETCODES.AUTH_RES or not authObject?.response?.value or not authObject?.response?.uID
        logConnectionInfo("AUTH_RES INVALID")
        @authenticated = false
        return

      if authObject.response.value is true
        @uID = authObject.response.uID
        logConnectionInfo("Client verified.")
        @authenticated = true

        @ws.onmessage = @handleMessage

    @sendAuthentication(sessid) until @authenticated
    console.log("Auth")
    return true

logConnectionInfo = (info) ->
  console.log(info)

createMsgRequest = (msgObj) ->
  request = {
    type: NETCODES.MSG_SEND_REQ,
    message: msgObj
    }

  return request

chatServer = "ws://127.0.0.1:1337"

ws = new WebSocket(chatServer)
SESSID = window.getCookie("PORTALNSESSID")

cc = new ChatConnection(ws)
# cc.authenticate(SESSID)
cc.on "message", (msgObject) ->
  # dh.addMessageToPage(msgObject)
  console.log(msgObject)

window.cc = cc