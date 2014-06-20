mod =

  identifier: "flashMessages"
  name: 'Flash Message Display'
  description: "Handles automatic flash message display for HTML and AJAX calls"

  flash:
    messages: {}

  init: (main) ->
    main.registerCallback 'ajaxComplete', 'Show AJAX flash messages', mod.handleAjaxFlash
    main.registerCallback 'documentReady', 'Show static flash messages', mod.handleStaticFlash

  config:
    conversions:
      bootstrap:
        notice:  'alert alert-success'
        warning: 'alert'
        error:   'alert alert-danger'
      pnotify:
        notice:  'info'
        success: 'success'
        warning: 'notice'
        error:   'error'

  # Handles flash messages which came in through an AJAX request.
  # They are sent in a special header field by the server and
  # can be taken from there. This method is automatically called
  # whenever an AJAX request finished.
  #--------------------------------------------------------------
  handleAjaxFlash: (context) ->
    msg     = context.request.getResponseHeader('X-Message')
    msgType = context.request.getResponseHeader('X-Message-Type')
    if msg && msgType
      mod.flash.messages[msgType] = msg
      mod.displayFlashMessages()

  # Handles flash messages which came in through a normal HTML
  # call. These are automatically written to a meta-tag
  # by the server and can be fetched from there.
  #--------------------------------------------------------------
  handleStaticFlash: (context) ->
    msgType = jQuery('meta[name=flash-type]').attr("content")
    msg     = jQuery('meta[name=flash-message]').attr("content")
    if msg && msgType
      mod.flash.messages[msgType] = msg
      mod.displayFlashMessages()

  # Actually displays the flash messages for the last request
  # in the page. It will append bootstrap alerts to the element
  # specified in the classes-section (usually #flash).
  #--------------------------------------------------------------
  displayFlashMessages: () ->
    jQuery.each Object.keys(mod.flash.messages), (index, value) ->
      if value?
        autoJS.log 'flash messages', "Displaying type: #{value}"

        options =
          title: i18n.autoJS.flash[value],
          text: mod.flash.messages[value],
          type: autoJS.config.flashMessages.conversions.pnotify[value],
          width: '500px'

        jQuery.pnotify(options)

        #Delete the displayed flash message
        delete mod.flash.messages[value]

autoJS.registerModule mod