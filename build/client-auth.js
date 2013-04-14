// Generated by CoffeeScript 1.6.1
(function() {
  var ChatClient, MS,
    _this = this;

  MS = window.Message;

  ChatClient = (function() {

    function ChatClient(server, sessid) {
      var _this = this;
      this.sessid = sessid;
      this.handleIncoming = function(incObject) {
        return ChatClient.prototype.handleIncoming.apply(_this, arguments);
      };
      this.ws = new WebSocket(server);
      this.uID = void 0;
      this.authenticated = false;
      this.msgID = 10;
      this.callbacks = {
        "cstatus": void 0,
        "message": void 0,
        "confirmation": void 0
      };
      this.ws.onmessage = function(message) {
        return _this.handleIncoming(MS.deserialize(message.data));
      };
      this.ws.onopen = function() {
        _this.emit("cstatus", "Connected to IM Server.");
        return _this.sendAuthChallenge();
      };
    }

    ChatClient.prototype.handleIncoming = function(incObject) {
      switch (MS.typeOf(incObject)) {
        case MS.CODES.AUTH_RES:
          this.authenticate(incObject);
          break;
        case MS.CODES.MSG_SEND_RES:
          this.emit("confirmation", incObject.response);
          break;
        case MS.CODES.MSG:
          this.emit("message", incObject.message);
      }
      return void 0;
    };

    ChatClient.prototype.transmit = function(msgObject) {
      try {
        this.ws.send(MS.serialize(msgObject));
        return null;
      } catch (error) {
        return error;
      }
    };

    ChatClient.prototype.transmitMessage = function(msgObject) {
      var error;
      error = this.transmit(MS.createMsgSendReq(msgObject));
      if (error != null) {
        return error;
      }
    };

    ChatClient.prototype.createMessageWithID = function(msgObject) {
      msgObject.id = this.msgID;
      this.msgID++;
      return msgObject;
    };

    ChatClient.prototype.emit = function(event, arg) {
      var callback, evt, _ref, _results;
      _ref = this.callbacks;
      _results = [];
      for (evt in _ref) {
        callback = _ref[evt];
        if (evt === event && typeof callback === "function") {
          _results.push(callback(arg));
        }
      }
      return _results;
    };

    ChatClient.prototype.on = function(event, callback) {
      var _this = this;
      if (typeof event === "string" && typeof callback === "function") {
        return (function() {
          return _this.callbacks[event] = callback;
        })();
      }
    };

    ChatClient.prototype.authenticate = function(authObject) {
      if (!MS.assert(authObject, MS.CODES.AUTH_RES)) {
        this.emit("cstatus", "AUTH_RES INVALID");
        this.authenticated = false;
        return false;
      }
      if (authObject.response.value) {
        this.uID = authObject.response.uID;
        this.emit("cstatus", "Client verified.");
        this.authenticated = true;
        return true;
      } else {
        this.emit("cstatus", "Client denied.");
        this.authenticated = false;
        return false;
      }
    };

    ChatClient.prototype.sendAuthChallenge = function() {
      this.emit("cstatus", "Authorizing...");
      return this.transmit(MS.createAuthReq(this.sessid));
    };

    return ChatClient;

  })();

  window.ChatClient = ChatClient;

}).call(this);
