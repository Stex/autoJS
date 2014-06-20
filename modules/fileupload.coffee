mod =
  # This module uses the jQuery fileupload plugin (http://blueimp.github.io/jQuery-File-Upload/)

  identifier: "fileUpload"
  name: 'jQuery Fileuploads for AJAX calls'
  description: "Handles automatic initialization for jQuery file upload fields"

  init: (main) ->
    main.registerCallback 'documentReady', 'Initialize single file upload fields without form control', mod.createFileUploadFields
    main.registerCallback 'ajaxComplete', 'Initialize single file upload fields without form control', mod.createFileUploadFields

    main.registerCallback 'documentReady', 'Initialize form file upload fields', mod.initFormFileUploads
    main.registerCallback 'ajaxComplete', 'Initialize form file upload fields', mod.initFormFileUploads

  config:
    selectors:
      fileUpload:     '[data-init=fileupload]'
      dropzone:       '[data-toggle=dropzone]'
      fileuploadForm: 'form[data-init=fileupload-form]'

  # Initializes multiple file upload fields in one form
  # This method has to be used for remote forms as otherwise
  # only one file can be uploaded (probably, the method below
  # should be removed completely as in Rails there should always
  # be a form for security issues)
  #
  # The function assigns 2 data attributes to the form
  # which will hold the file contents and param names for
  # all files that were selected for uploading. On submit,
  # all these files are uploaded at the same time.
  #
  # @todo: If the same file field contains multiple files,
  #        the existing file in the files list should be deleted.
  #        Add a setting for this as we might want multi file uploads later.
  #
  #--------------------------------------------------------------
  initFormFileUploads: (context) ->
    jQuery(autoJS.config.fileUpload.selectors.fileuploadForm).each () ->
      form = jQuery(@)

      if form.data('sxm.formFileUploads.initialized')
        autoJS.log 'fileupload', 'already initialized form'
        autoJS.log 'fileupload', form
      else
        autoJS.log 'fileupload', 'initializing form:'
        autoJS.log 'fileupload', form

        form.data('sxm.formFileUploads.initialized', true)
        form.data('sxm.formFileUploads.filesList', [])
        form.data('sxm.formFileUploads.paramsList', [])

        fileUpload = form.fileupload
          autoUpload: false
          fileInput: form.find('input[type=file]')
          'add': (e, data) ->
            target     = jQuery(e.delegateTarget)
            file       = data.files[0]
            filesList  = form.data('sxm.formFileUploads.filesList')
            paramsList = form.data('sxm.formFileUploads.paramsList')

            autoJS.log 'fileupload', 'Adding file to form queue'
            autoJS.log 'fileupload', file

            filesList.push(file)
            paramsList.push(e.delegateTarget.name)

            if target.data('fileDisplay')?
              previewElem = jQuery(target.data('fileDisplay'))
              if ~file.type.indexOf('image') != 0
                autoJS.log 'fileupload', 'generating preview image'
                reader = new FileReader()
                reader.onload = (e) ->
                  #If the previewElem is already an image tag, we can just
                  #exchange its src, otherwise, we create a new image
                  if previewElem.prop('tagName') == 'IMG'
                    previewElem.attr('src', e.target.result)
                  else
                    image = jQuery("<img/>")
                    image.attr('src', e.target.result)
                    image.addClass('img-responsive')
                    previewElem.html('')
                    previewElem.append(image)
                reader.readAsDataURL(file)
              else
                previewElem.text("#{file.name} (#{file.size} Byte)")

            form.data('sxm.formFileUploads.filesList', filesList)
            form.data('sxm.formFileUploads.paramsList', paramsList)

        #Bind a new event to the form's submit button that
        #will trigger all file uploads together with the form's data
        #instead of the default submit action.
        form.find('input[type=submit]').on 'click', (e) ->
          filesList  = form.data('sxm.formFileUploads.filesList')

          if filesList.length > 0
            e.preventDefault()
            paramsList = form.data('sxm.formFileUploads.paramsList')
            fileUpload.fileupload('send', {files: filesList, paramName: paramsList})

  # Creates file upload fields using the jQuery fileUpload plugin
  # Attributes:
  #   data-url                 -- The url to upload the file to
  #   data-drop-zone           -- A selector to specify a zone which accepts
  #                               files dragged from a file explorer to the browser
  #   data-wait-submit         -- If set to "true", the file will not be uploaded
  #                               until the form's submit button is clicked.
  #----------------------------------------------------------------------------
  createFileUploadFields: (context) ->
    jQuery(autoJS.config.fileUpload.selectors.fileupload).each () ->
      elem = jQuery(@)

      if elem.data('blueimpFileupload')
        autoJS.log 'fileupload', 'skipping already initialized field'
        autoJS.log 'fileupload', elem
        return true
      else
        autoJS.log 'fileupload', 'initializing file upload field'
        autoJS.log 'fileupload', elem

        options = {}
        options['url']      = elem.attr("data-url") || null
        options['type']     = elem.attr("data-type") || "POST"
        options['dropZone'] = jQuery(elem.attr("data-drop-zone") || null)
        options['singleFileUploads'] = false

        if elem.attr('data-wait-submit') == 'true'
          options['add'] = (e, data) ->
            jQuery(@).next('.filename').html "#{data.files[0].name} (#{data.files[0].size} Bytes)"

            filesList = data.form.data('file-upload-list') || []
            filesList.push(data.files[0])
            data.form.data('file-upload-list', filesList)

          options['autoUpload'] = false

          form = elem.parents('form')
          unless form.data('sxm-file-upload-initialized')
            form.data('sxm-file-upload-initialized', true)
            form.find('input[type=submit]').on 'click', (e) ->
              e.preventDefault();
              elem.fileupload('send', {files: form.data('file-upload-list')})

            #TODO: It is definitely bad pracise to remove the remove the onsubmit handler completely,
            #      we'll have to find a better way to supress rails' ajax form behaviour.
#              data.form.attr('onsubmit', 'return false;') if data.form.attr('onsubmit')?
#              data.form.find('input[type=submit]').on 'click', () ->
#                console.log data.submit()

        elem.fileupload options

  # Creates an indicator for file upload drop zones
  #----------------------------------------------------------------------------
  createDropZoneIndicators: () ->
    jQuery(document).on("dragover", autoJS.config.fileUpload.selectors.dropzone, (event) ->
      elem = jQuery(@)
      #Remove the hover class from all other dropzones
      jQuery(autoJS.config.selectors.dropzone).removeClass("hover")
      elem.addClass("hover")
    )
    jQuery(document).on("dragleave", autoJS.config.selectors.dropzone, (event) ->
      elem = jQuery(@)
      elem.removeClass("hover")
    )

autoJS.registerModule mod