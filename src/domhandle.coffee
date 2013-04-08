class window.DOMHandle
  constructor: ->
    @chatStatus = null
    @chatMainOutput = null
    @chatTextarea = null

    @pageHeader = @getHeader()
    @pageTitle = @getTitle()
    @pageBody = @getBody()
    @pageNavButton = @getNavButton()
    @pageCopyright = @getCopyright()

    @callbacks = {
      "submit": null,
    }

    @styles = {
      chatStatus: {
        "width": "100%",
        "padding": "7px",
        "text-align": "left",
        "background-color": "#fff"
      },

      chatMainOutput: {
        "height": "200px",
        "text-align": "left",
        "background-color": "#fff"
      },

      chatTextarea: {
        "font-size": "100%"
        "margin-top": "15px",
        "background-color": "#fff"
      }
    }

    @bodyHTML = """
                <div id="chatStatus"></div>
                <div id="chatMainOutput"></div>
                <input type="text" id="chatTextarea">
               """

    @messageAuthorHTML = """<div class="messageAuthor"></div>"""
    @messageAuthorCSS = {
      "width": "100%";
      "border-color": "#ddd";
      "border-style": "solid";
      "padding": "7px 15px 3px 15px";
      "font-family": "Rockwell, KuristaSemibold, Arial";
      "font-size": "16px";
      "background-color": "#fff";
      "float": "left";
      "color": "#41b7d8";
    }

    @messageContentHTML = """<div class="messageContent"></div>"""
    @messageContentCSS = {
      "width": "100%";
      "padding": "3px 15px 8px 15px";
      "background-color": "#fff";
      "float": "left";
      "border-bottom": "1px solid #eee";
      "line-height": "120%";
    }

  initDOMChange: ->
    @pageHeader.html("SkolportalN 2.0 Instant Messaging Service")
    @pageTitle.html("")
    @pageBody.html("Body")
    @pageNavButton.html("Chat")
    @pageCopyright.html("Injected by Epoch2")

    @pageBody.html(@bodyHTML)

    @chatStatus = $("#chatStatus")
    @chatMainOutput = $("#chatMainOutput")
    @chatTextarea = $("#chatTextarea")

    @chatStatus.css(@styles.chatStatus)
    @chatMainOutput.css(@styles.chatMainOutput)
    @chatTextarea.css(@styles.chatTextarea)

    @chatStatus.html("Status goes here")

    @chatTextarea.focus()

    # Bind events

    @chatTextarea.keypress =>
      if event.keyCode is 13
        callback(@chatTextarea.val()) for evt, callback of @callbacks when evt is "submit"
        @chatTextarea.val("")

  getHeader: ->
    $("div.header")

  getTitle: ->
    $("div.title")

  getBody: ->
    $("div.body")

  getNavButton: ->
    $("a:contains(Resa)")

  getCopyright: ->
    $("#copyright")

  on: (event, callback) ->
    @callbacks[event] = callback

  addMessageToPage: (author, content) ->
    authorTag = $(@messageAuthorHTML)
    authorTag.css(@messageAuthorCSS)
    authorTag.html(author)

    contentTag = $(@messageContentHTML)
    contentTag.css(@messageContentCSS)
    contentTag.html(content)

    authorTag.appendTo(@chatMainOutput)
    contentTag.appendTo(@chatMainOutput)