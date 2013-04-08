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
      "submit": undefined,
    }

    @CSS = {
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
      },

      messageAuthor: {
        "width": "100%";
        "border-color": "#ddd";
        "border-style": "solid";
        "padding": "7px 15px 3px 15px";
        "font-family": "Rockwell, KuristaSemibold, Arial";
        "font-size": "16px";
        "background-color": "#fff";
        "float": "left";
        "color": "#41b7d8";
      },

      messageContent: {
        "width": "100%";
        "padding": "3px 15px 8px 15px";
        "background-color": "#fff";
        "float": "left";
        "border-bottom": "1px solid #eee";
        "line-height": "120%";
      }
    }

    @HTML = {
      body: """
                <div id="chatStatus"></div>
                <div id="chatMainOutput"></div>
                <input type="text" id="chatTextarea">
               """,

      messageAuthor: """<div class="messageAuthor"></div>""",
      messageContent: """<div class="messageContent"></div>"""
    }

  initDOMChange: ->
    @pageHeader.html("SkolportalN 2.0 Instant Messaging Service")
    @pageTitle.html("")
    @pageBody.html("Body")
    @pageNavButton.html("Chat")
    @pageCopyright.html("Injected by Epoch2")

    @pageBody.html(@HTML.body);

    @chatStatus = $("#chatStatus")
    @chatMainOutput = $("#chatMainOutput")
    @chatTextarea = $("#chatTextarea")

    @chatStatus.css(@CSS.chatStatus)
    @chatMainOutput.css(@CSS.chatMainOutput)
    @chatTextarea.css(@CSS.chatTextarea)

    @chatStatus.html("Not connected.")

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

  unixToTime: (unixtime) ->
    date = new Date(Number(unixtime))
    return {
      hours: date.getHours(),
      minutes: date.getMinutes(),
      seconds: date.getSeconds()
    }

  addZeroesToTime: (timeObject) ->
    addzero = (time) ->
      return if "#{time}".length is 1 then "0#{time}" else "#{time}"

    timeObject[key] = addzero(time) for key, time of timeObject
    return timeObject

  on: (event, callback) ->
    @callbacks[event] = callback

  addMessageToPage: (messageObject) ->
    authorTag = $(@HTML.messageAuthor)
    authorTag.css(@CSS.messageAuthor)
    timeStamp = @addZeroesToTime(@unixToTime(messageObject.timeStamp))
    timeStampString = "#{timeStamp.hours}:#{timeStamp.minutes}:#{timeStamp.seconds}"
    authorTag.html("#{timeStampString} - #{messageObject.fromUser}")

    contentTag = $(@HTML.messageContent)
    contentTag.css(@CSS.messageContent)
    contentTag.html(messageObject.content)

    authorTag.appendTo(@chatMainOutput)
    contentTag.appendTo(@chatMainOutput)