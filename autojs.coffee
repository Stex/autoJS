window.autoJS =

  #----------------------------------------------------------------
  #                        Default Configuration
  #----------------------------------------------------------------

  config:
    csrf:
      param: null
      token: null

    #If set to +true+, there will be a lot of debugging
    #output for each of the modules the core.
    verbose: false

  #----------------------------------------------------------------
  #                        Loaded Modules
  #----------------------------------------------------------------

  modules: []

  #
  # Registers a new autoJS module
  #
  registerModule: (mod) ->
    if mod.identifier? && mod.identifier != ""
      @modules.push mod
      @config[mod.identifier] = mod.config if mod.config?
      mod.init(autoJS) if mod.init?
    else
      console.log "You tried to init a module without identifier!"

  #
  # Returns a list of all currently loaded modules
  #
  loadedModules: () ->
    autoJS.modules.map (mod) -> mod.name

  #----------------------------------------------------------------
  #                      Registered Callbacks
  #----------------------------------------------------------------

  callbacks:
    documentReady: []
    afterAjax:     []
    beforeAjax:    []

  #
  # Registers a callback function to be run after / before
  # other events in the system. The most popular ones here are:
  #   - afterAjax
  #   - beforeAjax
  #   - domReady
  #
  # However, AutoJS plugins may register their own callback namespaces
  # here and get them executed through +runCallbacks+
  #
  # @param [String] ns
  #   The callback we want to attach the function to, see above
  #
  # @param [String] desc
  #   Short description of what the method will do, mainly for logging purposes
  #
  # @param [Function] fun
  #   The function to be executed.
  #   It should accept an object as parameter which will
  #   include additional information about the context
  #
  registerCallback: (ns, desc, fun) ->
    if !fun?
      autoJS.log 'core', "Tried to register an invalid callback. Details:"
      autoJS.log 'core', "Namespace: #{ns}, Description: #{desc}"
    else
      @.callbacks[ns] = [] unless @.callbacks[ns]?
      @.callbacks[ns].push(fun)

  #
  # Runs all currently registered callbacks for the given
  # callback namespace.
  #
  # @param [String] ns
  #   The callback namespace to run. Default namespaces are
  #     - ajaxSend
  #     - ajaxComplete
  #     - documentReady
  #   but modules may define and execute their own namespaces
  #
  # @param [Object] context
  #   Object (Hash) which is passed to the callback function.
  #
  runCallbacks: (ns, context) ->
    return false unless @.callbacks[ns]?
    context = {} unless context?
    context['callback'] = ns

    autoJS.log 'core', "running callbacks for #{ns}, context is:"
    autoJS.log 'core', context

    jQuery.each @.callbacks[ns], () -> @(context)

  #
  # Logging-Function which is used by all modules.
  # It will only output the messages to console if the
  # +verbose+ setting is set to +true+
  #
  log: (ns, msg) ->
    if autoJS.config.verbose
      if typeof msg == 'string'
        console.debug("autoJS :: #{ns} :: #{msg}")
      else
        console.debug(msg)


  loadCSRF: () ->
    autoJS.config.csrf.param = jQuery('meta[name=csrf-param]').attr("content")
    autoJS.config.csrf.token = jQuery('meta[name=csrf-token]').attr("content")


autoJS.registerCallback 'documentReady', 'Hiding elements by class', autoJS.hideClassElements
autoJS.registerCallback 'documentReady', 'Loading CSRF data from meta tags', autoJS.loadCSRF

#----------------------------------------------------------------
#                        Callback execution
#----------------------------------------------------------------

#
# Runs registered callbacks once a jQuery ajax call was finished
#
jQuery(document).on "ajaxComplete", (event, request, options) ->
  autoJS.runCallbacks 'ajaxComplete',
    'event': event
    'request': request
    'options': options

#
# Runs registered Callbacks once a jQuery ajax call starts
#
jQuery(document).on "ajaxSend", (event, request, options) ->
  autoJS.runCallbacks 'ajaxSend',
    'event': event
    'request': request
    'options': options

#
# Runs registered Callbacks once the document finished loading
#
jQuery(document).ready () ->
  autoJS.runCallbacks 'documentReady'