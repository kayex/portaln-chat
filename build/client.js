// Generated by CoffeeScript 1.6.1
(function() {
  var SESSID, cc, chatServer;

  chatServer = "wss://arch.jvester.se:1337";

  SESSID = window.getCookie("PORTALNSESSID");

  cc = new ChatClient(chatServer, SESSID);

  cc.on("cstatus", function(status) {
    return console.log(status);
  });

  cc.on("message", function(msgObject) {
    return console.log(msgObject);
  });

  cc.on("confirmation", function(msgObject) {
    return console.log(msgObject);
  });

  window.cc = cc;

}).call(this);
