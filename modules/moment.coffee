mod =

  #Uses the Moment.js library.

  #
  # Rails helper for easier usage:
  #
  #  def moment(time, options = {})
  #    options[:class] ||= 'moment'
  #    content_tag(:abbr, 'Local time: ' + l(time.in_time_zone), options.merge(:title => time.iso8601))
  #  end
  #

  identifier: "moment"
  name: 'Moment.js integration'
  description: "Initialization for moment ABBRs"

  init: (main) ->
    main.registerCallback 'documentReady', 'Load Moment ABBRs', mod.initializeMomentAbbrs
    main.registerCallback 'ajaxComplete', 'Load Moment ABBRs', mod.initializeMomentAbbrs

  config:
    selector: 'abbr[data-moment]'

  # Updates abbr tags with the correct localized time
  # using the Moment.js libary
  #--------------------------------------------------------------
  initializeMomentAbbrs: () ->
    moment.lang('en-gb')
    jQuery(autoJS.config.moment.selector).each () ->
      elem = jQuery(@)
      return true if elem.data('momentInitialized')

      momentString = moment(elem.attr('title')).calendar()
      elem.attr('title', elem.html())
      elem.html(momentString)
      elem.data('momentInitialized', true)

autoJS.registerModule mod