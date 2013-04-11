// Generated by CoffeeScript 1.6.1
(function() {
  var ClientHolder, MS, NETCODES, WebSocketServer, authenticateConnection, ch, checkSession, createClient, createMessageForWire, handleMessageRequest, handleRequest, log, logMessage, logMessageToDisk, logServerInfo, logUserInfo, postPasswd, request, transmitMessage, wss, wssConfig;

  WebSocketServer = require("ws").Server;

  log = require("util").log;

  request = require("request");

  NETCODES = require("./netcodes.js").NETCODES;

  MS = require("./message.js").MessageSerializer;

  postPasswd = "94bfd1921fe7663e776528e678e56f33";

  ClientHolder = (function() {

    function ClientHolder() {
      this.clients = [];
    }

    ClientHolder.prototype.addClient = function(client) {
      return this.clients.push(client);
    };

    ClientHolder.prototype.delClientByWS = function(ws) {
      var client, i, _i, _len, _ref, _results;
      _ref = this.clients;
      _results = [];
      for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
        client = _ref[i];
        if ((client != null ? client.ws : void 0) === ws) {
          _results.push(this.clients.splice(i, 1));
        }
      }
      return _results;
    };

    ClientHolder.prototype.getClientByuID = function(uID) {
      var client, _i, _len, _ref;
      _ref = this.clients;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        client = _ref[_i];
        if ((client != null ? client.uID : void 0) === uID) {
          return client;
        }
      }
      return null;
    };

    ClientHolder.prototype.getClientByWS = function(ws) {
      var client, _i, _len, _ref;
      _ref = this.clients;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        client = _ref[_i];
        if ((client != null ? client.ws : void 0) === ws) {
          return client;
        }
      }
      return null;
    };

    ClientHolder.prototype.getClientCount = function() {
      return this.clients.length;
    };

    return ClientHolder;

  })();

  createClient = function(ws, uID) {
    return {
      ws: ws,
      uID: uID
    };
  };

  checkSession = function(sessID) {
    var a, checkObject;
    a = 0;
    checkObject = void 0;
    request.post("http://latest.portaln.se/skola/chatapi.php", {
      form: {
        passwd: postPasswd,
        SESSID: sessID
      }
    }, function(error, response, body) {
      console.log("Error " + error);
      console.log("Response " + response);
      console.log("Body: " + body);
      if (response.statusCode === 200 && !error) {
        return checkObject = JSON.parse(body);
      }
    });
    while (checkObject == null) {
      a = 0;
    }
    return checkObject;
  };

  authenticateConnection = function(ws, authReq) {
    var authObject, checkResponse;
    console.log("Authenticating connection");
    authObject = JSON.parse(authReq);
    console.log(authObject);
    if ((authObject != null ? authObject.type : void 0) === !NETCODES.AUTH_REQ || !(authObject != null ? authObject.SESSID : void 0)) {
      ws.send({
        type: NETCODES.AUTH_RES,
        response: {
          value: false,
          reason: "AUTH_REQ INVALID"
        }
      });
      ws.close(4025, "AUTH_REQ INVALID");
      return false;
    }
    checkResponse = checkSession(authObject.SESSID);
    if ((checkResponse != null ? checkResponse.loggedin : void 0) === !true) {
      ws.send(MS.serialize({
        type: NETCODES.AUTH_RES,
        response: {
          value: false,
          reason: "SESSION INVALID"
        }
      }));
      ws.close(4026, "Session invalid");
      return false;
    }
    if (!(checkResponse != null ? checkResponse.uID : void 0)) {
      ws.send(MS.serialize({
        type: NETCODES.AUTH_RES,
        response: {
          value: false,
          reason: "NO LEGAL UID"
        }
      }));
      ws.close(4027, "NO LEGAL UID");
      return false;
    }
    if (checkResponse.loggedin === true) {
      ws.send(MS.serialize({
        type: NETCODES.AUTH_RES,
        response: {
          value: true,
          uID: checkResponse.uID
        }
      }));
      return createClient(ws, checkResponse.uID);
    }
    return false;
  };

  handleRequest = function(ws, req) {
    var parsedReq;
    parsedReq = MS.deserialize(req);
    switch (parsedReq.type) {
      case NETCODES.MSG_SEND_REQ:
        return handleMessageRequest(ws, parsedReq.message);
    }
  };

  createMessageForWire = function(msgObj) {
    var message;
    message = {
      type: NETCODES.MSG,
      message: msgObj
    };
    return message;
  };

  transmitMessage = function(ws, msgObj) {
    return ws.send(MS.serialize(createMessageForWire(msgObj)));
  };

  logUserInfo = function(info) {
    return log("@ " + info);
  };

  logServerInfo = function(info) {
    return log("# " + info);
  };

  logMessage = function(msgObj) {
    return log("> " + msgObj.fromuID + " -> " + msgObj.touID + ": " + msgObj.content);
  };

  logMessageToDisk = function(msgObj) {
    return console.log("Message to disk");
  };

  handleMessageRequest = function(ws, msgObj) {
    var clientFrom, clientTo;
    console.log("Handling message request");
    clientFrom = ch.getClientByWS(ws);
    if (clientFrom == null) {
      console("this client is not registered");
      ws.send(MS.serialize({
        type: NETCODES.MSG_SEND_RES,
        response: {
          id: msgObj.id,
          value: false,
          reason: "not-connected"
        }
      }));
    }
    console.log("fromClient is logged in!");
    clientTo = ch.getClientByuID(msgObj.touID);
    if (clientTo != null) {
      transmitMessage(clientTo.ws, msgObj);
    }
    console.log("Sending response");
    ws.send(MS.serialize({
      type: NETCODES.MSG_SEND_RES,
      response: {
        id: msgObj.id,
        value: true
      }
    }));
    logMessage(msgObj);
    return logMessageToDisk(msgObj);
  };

  wssConfig = {
    port: 1337
  };

  wss = new WebSocketServer(wssConfig);

  ch = new ClientHolder();

  wss.on("connection", function(ws) {
    ws.on("message", function(msg) {
      var authClient;
      authClient = authenticateConnection(ws, msg);
      if (authClient != null) {
        ch.addClient(authClient);
      } else {
        return;
      }
      return ws.on("message", function(msg) {
        return handleRequest(ws, msg);
      });
    });
    return ws.on("close", function(code, reason) {
      if (ch.getClientByWS(ws)) {
        logUserInfo("" + (ch.getClientByWS(ws).uID) + " disconnected.");
        return ch.delClientByWS(ws);
      }
    });
  });

}).call(this);
