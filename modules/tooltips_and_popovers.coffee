mod =

  identifier: "popovers"
  name: 'Popovers and Tooltips'
  description: "Initializes and enhances bootstrap tooltips and popovers"

  init: (main) ->
    main.registerCallback 'documentReady', 'Static Tooltip initialization', mod.initializeTooltips
    main.registerCallback 'ajaxComplete', 'AJAX tooltip initialization', mod.initializeTooltips

  # Bootstrap tooltips are no longer automatically loaded,
  # so we have to initialize them ourselves.
  #--------------------------------------------------------------
  initializeTooltips: (context) ->
    jQuery("[data-toggle='tooltip']").tooltip()
    jQuery("a[data-toggle='popover']").popover().on 'shown.bs.popover', () ->
      #Bind the destroy event to the popover close links.
      popElem     = jQuery(@)
      popElemPure = @

      #Hide other popovers if a selector was specified.
      if popElem.data('close-other')?
        jQuery(popElem.data('close-other')).each () ->
          otherElem = jQuery(@)
          if @ != popElemPure
            otherElem.popover('hide')
            otherElem.data('bs.popover').tip().hide()

      #Append a close link to the title if it does not already contain one
      if popElem.data('bs.popover').tip().find('.popover-title > a.close').length == 0
        closeElem = jQuery('<a data-hide="popover" class="close pull-right">&times;</a>')
        popElem.data('bs.popover').tip().find('.popover-title').append(closeElem)

      popElem.data('bs.popover').tip().find("[data-hide=popover]").on 'click', () ->
        popElem.popover('hide')
        #There seems to be a problem with the "fade" functionality on tooltips,
        #tooltips which are hidden via 'hide' are still clickable.
        popElem.data('bs.popover').tip().hide()
        false


    #Prevent the default link action, so we don't have to specify
    # onclick="return false;"
    jQuery("a[data-toggle='popover']").click (event) ->
      event.preventDefault()
      false

autoJS.registerModule mod
