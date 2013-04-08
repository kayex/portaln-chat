dh = new window.DOMHandle()
dh.initDOMChange()
dh.addMessageToPage("Epoch2", "Type something and press enter :)")
dh.on "submit", (text) ->
  dh.addMessageToPage("User", text)