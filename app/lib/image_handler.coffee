Resize = require 'lib/image_resizer'

resize = new Resize()
resize.init()

handlers =
  # uploadResizedFile: (file)->
  #   initialSize = file.size
  #   resize.photo file, 1200, 'file', (resizedFile) =>
  #     resizedSize = resizedFile.size
  #     @upload resizedFile, (response) ->
  #       console.log response.url

  # displayThumbnail: (file, selector)->
  #   resize.photo file, 600, 'dataURL', (thumbnail) ->
  #     console.log 'Display the thumbnail to the user: ', thumbnail
  #     $(selector).append "<img src='#{thumbnail}'>"

  addDataUrlToArray: (file, array, event)->
    resize.photo file, 600, 'dataURL', (data)->
      array.unshift(data)
      if array.trigger? and event?
        array.trigger(event)

  upload: (dataURLs) ->
    formData = new FormData()
    i = 0

    dataURLs.forEach (dataURL)->
      unless _.isDataUrl dataURL
        throw new Error 'image upload requires a dataURL'
      blob = window.dataURLtoBlob(dataURL)
      formData.append("file-#{i}", blob)
      i++

    def = Promise.defer()
    request = new XMLHttpRequest()
    request.onreadystatechange = ->
      if request.readyState is 4
        def.resolve request.response

    request.onerror = -> def.reject(request)
    request.open 'POST', '/api/upload'
    request.responseType = 'json'
    request.send formData


    return def.promise

  del: (imageUrlToDelete)->
    _.inspect imageUrlToDelete, 'imageUrlToDelete'
    $.postJSON '/api/upload/delete', {urls: imageUrlToDelete}
    .then _.Log('image del res')
    .fail _.Error('image del err')


module.exports = handlers