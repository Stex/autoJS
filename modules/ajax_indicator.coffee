mod =

  identifier: "ajaxIndicator"
  name: 'Ajax Indicator'
  description: "Displays an indicator element on each AJAX request"

  init: (main) ->
    main.registerCallback 'ajaxSend', 'Display AJAX indicator', mod.displayIndicator
    main.registerCallback 'ajaxComplete', 'Hide AJAX indicator', mod.hideIndicator

  config:
    requestCount: 0
    indicatorElement: null

  displayIndicator: (context) ->
    autoJS.log 'ajax indicator', 'ajaxSend, requestCount = ' + autoJS.config.ajaxIndicator.requestCount

    if autoJS.config.ajaxIndicator.requestCount == 0
      autoJS.log  'showing indicator element'

      autoJS.config.ajaxIndicator.indicatorElement = jQuery.pnotify
        title:    i18n.autoJS.ajaxIndicator.title
        text:     i18n.autoJS.ajaxIndicator.text
        nonblock: true
        closer:   false
        sticker:  false
        hide:     false
        type:    'notice'
        icon:    'fa fa-spinner icon-spinner fa-spin'
    autoJS.config.ajaxIndicator.requestCount++

  hideIndicator: (context) ->
    autoJS.log 'ajax indicator', 'ajaxComplete, requestCount = ' + autoJS.config.ajaxIndicator.requestCount

    if autoJS.config.ajaxIndicator.requestCount > 0
      autoJS.config.ajaxIndicator.requestCount--

    if autoJS.config.ajaxIndicator.requestCount == 0 && autoJS.config.ajaxIndicator.indicatorElement?
      autoJS.log 'ajax indicator', 'hiding indicator element'
      autoJS.config.ajaxIndicator.indicatorElement.pnotify_remove()

autoJS.registerModule mod