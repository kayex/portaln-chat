window.chatInit = (server) ->
  chatServer = server
  SESSID = window.getCookie("PORTALNSESSID")

  cc = new ChatClient(chatServer, SESSID)
  cc.on "cstatus", (status) ->
    console.log(status)
  cc.on "message", (msgObject) ->
    console.log(msgObject)
  cc.on "confirmation", (msgObject) ->
    console.log(msgObject)

  window.cc = cc