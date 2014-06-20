mod =

  identifier: "bootstrapTabExtensions"
  name: 'Bootstrap Tab Extensions'
  description: "Extensions for the default bootstrap 3 tab functionality"

  init: (main) ->
    main.registerCallback 'documentReady', 'Initialize AJAX tabs', mod.initializeAjaxTabs
    main.registerCallback 'ajaxComplete', 'Initialize AJAX tabs', mod.initializeAjaxTabs

    main.registerCallback 'documentReady', 'Initialize Disabled Tabs', mod.initializeDisabledTabs
    main.registerCallback 'ajaxComplete', 'Initialize Disabled Tabs', mod.initializeDisabledTabs

  initializeAjaxTabs: (context) ->
    ajaxRequest = (linkElem) ->
      format = linkElem.attr('data-format') || 'js'
      jQuery(linkElem.attr("href")).html("Loading...")
      jQuery.ajax(
        type: "GET",
        url: linkElem.attr("data-ajax-url")
        dataType: "html"
        data:
          format: format
      ).done (html) ->
        contentElement = jQuery(linkElem.attr("href"))
        contentElement.data('tab.loaded', true)
        contentElement.html(html)

    jQuery('.tabbable').each () ->
      tabbable = jQuery(@)

      #Make sure that the event handlers are only registered once!
      unless tabbable.data('tabs.initialized')
        #Register ajax load handler
        tabbable.find('a[data-toggle="tab"][data-ajax-url]').on 'show.bs.tab', (event) ->
          t = jQuery(event.target)
          contentElement = jQuery(t.attr('href'))

          #Only reload content if the no-reload flag is not set.
          return if contentElement.data('tab.loaded') && t.data('noReload')
          ajaxRequest(t)

        #Load the content for an active ajax tab
        tabbable.find('li.active > a[data-toggle="tab"][data-ajax-url]').each () ->
          ajaxRequest(jQuery(@))

        #Run possible callbacks once the tab was shown
        tabbable.find('a[data-toggle="tab"]').on 'shown.bs.tab', (event) ->
          autoJS.runCallbacks('onTabShown', {'shownTab': jQuery(event.target).attr('href')})

        tabbable.data('tabs.initialized', true)


  # Disables bootstrap tabs as long as their containing <li>
  # has the 'disabled' class.
  #--------------------------------------------------------------
  initializeDisabledTabs: (context) ->
    jQuery('a[data-toggle="tab"]').on 'click', (event) ->
      return (!jQuery(@).parent('li').hasClass('disabled'))

autoJS.registerModule mod