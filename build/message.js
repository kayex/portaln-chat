// Generated by CoffeeScript 1.6.1

/*
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
*/


(function() {
  var Message;

  Message = (function() {
    var assertMessage, assertResponse,
      _this = this;

    function Message() {}

    Message.CODES = {
      AUTH_REQ: 0,
      AUTH_RES: 1,
      AUTH_EXTERNAL_RES: 2,
      MSG_SEND_REQ: 3,
      MSG_SEND_RES: 4,
      MSG: 5,
      USER_REQ: 6
    };

    Message.ASSERT_TYPE = {};

    assertResponse = function(response) {
      if ((response != null ? response.value : void 0) != null) {
        if (typeof (response != null ? response.value : void 0) !== "boolean") {
          return false;
        }
      }
      if ((response != null ? response.reason : void 0) != null) {
        if (typeof (response != null ? response.reason : void 0) !== "string") {
          return false;
        }
      }
      if ((response != null ? response.id : void 0) != null) {
        if (typeof (response != null ? response.id : void 0) !== "number") {
          return false;
        }
      }
      return true;
    };

    assertMessage = function(message) {
      if ((message != null ? message.timeStamp : void 0) != null) {
        if (typeof message.timeStamp !== "number") {
          return false;
        }
      } else {
        return false;
      }
      if ((message != null ? message.content : void 0) != null) {
        if (typeof message.content !== "string") {
          return false;
        }
      } else {
        return false;
      }
      if ((message != null ? message.touID : void 0) != null) {
        if (typeof message.touID !== "string") {
          return false;
        }
      } else {
        return false;
      }
      if ((message != null ? message.fromuID : void 0) != null) {
        if (typeof message.fromuID !== "string") {
          return false;
        }
      }
      if ((message != null ? message.id : void 0) != null) {
        if (typeof message.id !== "number") {
          return false;
        }
      }
      return true;
    };

    Message.ASSERT_TYPE[Message.CODES.AUTH_REQ] = function(req) {
      return req.type === Message.CODES.AUTH_REQ && typeof (req != null ? req.SESSID : void 0) === "string";
    };

    Message.ASSERT_TYPE[Message.CODES.AUTH_RES] = function(res) {
      return res.type === Message.CODES.AUTH_RES && (assertResponse(res.response) || (res.response == null));
    };

    Message.ASSERT_TYPE[Message.CODES.AUTH_EXTERNAL_RES] = function(res) {
      return typeof (res != null ? res.loggedin : void 0) === "boolean" && typeof (res != null ? res.uID : void 0) === "string";
    };

    Message.ASSERT_TYPE[Message.CODES.MSG_SEND_REQ] = function(req) {
      return req.type === Message.CODES.MSG_SEND_REQ && assertMessage(req.message);
    };

    Message.ASSERT_TYPE[Message.CODES.MSG_SEND_RES] = function(res) {
      return res.type === Message.CODES.MSG_SEND_RES && (assertResponse(res.response) || (res.response == null));
    };

    Message.ASSERT_TYPE[Message.CODES.MSG] = function(msg) {
      return msg.type === Message.CODES.MSG && assertMessage(msg.message);
    };

    Message.ASSERT_TYPE[Message.CODES.USER_REQ] = function(req) {
      return req.type === Message.CODES.USER_REQ && typeof (req != null ? req.uID : void 0) === "string";
    };

    Message.serialize = function(messageObject) {
      return JSON.stringify(messageObject);
    };

    Message.deserialize = function(message) {
      return JSON.parse(message);
    };

    Message.createAuthReq = function(sessid) {
      return {
        type: this.CODES.AUTH_REQ,
        SESSID: sessid
      };
    };

    Message.createAuthRes = function(value, extra) {
      var key, res, val;
      res = {
        type: this.CODES.AUTH_RES,
        response: {
          value: value
        }
      };
      for (key in extra) {
        val = extra[key];
        res.response[key] = val;
      }
      return res;
    };

    Message.createMsgSendReq = function(message) {
      return {
        type: this.CODES.MSG_SEND_REQ,
        message: message
      };
    };

    Message.createMsgSendRes = function(value, extra) {
      var key, res, val;
      res = {
        type: this.CODES.MSG_SEND_RES,
        response: {
          value: value
        }
      };
      for (key in extra) {
        val = extra[key];
        res.response[key] = val;
      }
      return res;
    };

    Message.createMsg = function(msg) {
      return {
        type: this.CODES.MSG,
        message: msg
      };
    };

    Message.createUserReq = function(uID) {
      return {
        type: this.CODES.USER_REQ,
        uID: uID
      };
    };

    Message.assert = function(obj, type) {
      return type === this.typeOf(obj);
    };

    Message.typeOf = function(obj) {
      var assert, type, _ref;
      _ref = this.ASSERT_TYPE;
      for (type in _ref) {
        assert = _ref[type];
        if (assert(obj)) {
          return Number(type);
        }
      }
    };

    return Message;

  }).call(this);

  if (typeof window === "undefined" || window === null) {
    module.exports = exports;
    exports.Message = Message;
  } else {
    window.Message = Message;
  }

}).call(this);
