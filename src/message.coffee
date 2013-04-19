###
Valid messages:

authreq = {
  type: Message.CODES.AUTH_REQ,
  SESSID: string
}

authres = {
  type: Message.CODES.AUTH_RES,
  value: boolean,
  (response): {
    (reason): string
  }
}

authextres = {
  type: Message.CODES.AUTH_EXTERNAL_RES,
  value: boolean,
  (response): {
    (reason): string
  }
}

msgsendreq = {
  type: Message.CODES.MSG_SEND_REQ,
  message: {
  timeStamp: number,
  touID: string,
  fromuID: string,
  (content): string,
  (id): number
  }
}

msgsendres = {
  type: Message.CODES.MSG_SEND_RES,
  response: {
    value: boolean,
    id: string
  }
}

msg = {
  type: Message.CODES.MSG,
  message: {
  timeStamp: number,
  touID: string,
  fromuID: string,
  (content): string,
  (id): number
  }
}

userreq = {
  type: Message.CODES.USER_REQ,
  uID: string
}
###

class Message
  @CODES = {
    AUTH_REQ: 0,
    AUTH_RES: 1,
    AUTH_EXTERNAL_RES: 2,
    MSG_SEND_REQ: 3,
    MSG_SEND_RES: 4,
    MSG: 5,
    USER_REQ: 6
  }

  @ASSERT_TYPE = {}

  assertResponse = (response) =>
    if response?.value?
      unless typeof response?.value is "boolean"
        return false
    if response?.reason?
      unless typeof response?.reason is "string"
        return false
    if response?.id?
      unless typeof response?.id is "number"
        return false
    return true

  assertMessage = (message) =>
    if message?.timeStamp?
      return false unless typeof message.timeStamp is "number"
    else
      return false

    if message?.content?
      return false unless typeof message.content is "string"
    else
      return false

    if message?.touID?
      return false unless typeof message.touID is "string"
    else
      return false

    if message?.fromuID?
      return false unless typeof message.fromuID is "string"

    if message?.id?
      return false unless typeof message.id is "number"
    return true

  @ASSERT_TYPE[@CODES.AUTH_REQ] = (req) => return req.type is @CODES.AUTH_REQ and typeof req?.SESSID is "string"
  @ASSERT_TYPE[@CODES.AUTH_RES] = (res) => return res.type is @CODES.AUTH_RES and (assertResponse(res.response) or not res.response?)
  @ASSERT_TYPE[@CODES.AUTH_EXTERNAL_RES] = (res) => return typeof res?.loggedin is "boolean" and typeof res?.uID is "string"
  @ASSERT_TYPE[@CODES.MSG_SEND_REQ] = (req) => return req.type is @CODES.MSG_SEND_REQ and assertMessage(req.message)
  @ASSERT_TYPE[@CODES.MSG_SEND_RES] = (res) => return res.type is @CODES.MSG_SEND_RES and (assertResponse(res.response) or not res.response?)
  @ASSERT_TYPE[@CODES.MSG] = (msg) => return msg.type is @CODES.MSG and assertMessage(msg.message)
  @ASSERT_TYPE[@CODES.USER_REQ] = (req) => return req.type is @CODES.USER_REQ and typeof req?.uID is "string"

  @serialize: (messageObject) ->
    return JSON.stringify(messageObject)

  @deserialize: (message) ->
    return JSON.parse(message)

  @createAuthReq: (sessid) ->
    return {
      type: @CODES.AUTH_REQ,
      SESSID: sessid
    }

  @createAuthRes: (value, extra) ->
    res = {
      type: @CODES.AUTH_RES,
      response: {
        value: value
      }
    }
    res.response[key] = val for key, val of extra
    return res

  @createMsgSendReq: (message) ->
    return {
      type: @CODES.MSG_SEND_REQ,
      message: message
    }

  @createMsgSendRes: (value, extra) ->
    res = {
      type: @CODES.MSG_SEND_RES,
      response: {
        value: value
      }
    }
    res.response[key] = val for key, val of extra
    return res

  @createMsg: (msg) ->
    return {
      type: @CODES.MSG,
      message: msg
    }

  @createUserReq: (uID) ->
    return {
      type: @CODES.USER_REQ,
      uID: uID
    }

  @assert: (obj, type) ->
    return type is @typeOf(obj)

  @typeOf: (obj) ->
    return Number(type) for type, assert of @ASSERT_TYPE when assert(obj)

if not window?
  module.exports = exports
  exports.Message = Message
else
  window.Message = Message