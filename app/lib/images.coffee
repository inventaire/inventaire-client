toDataURL = require 'to-data-url'
error_ = require 'lib/error'

handlers =
  addDataUrlToArray: (file, array, event)->
    resize.photo file, 600, 'dataURL', (data)->
      array.unshift(data)
      if array.trigger? and event?
        array.trigger(event)


  getUrlDataUrl: (url)->
    if /^http/.test url then url = app.API.proxy url
    new Promise (resolve, reject)->
      toDataURL url,
        callback: (err, res)->
          if err? then reject err
          else resolve res

  getElementDataUrl: ($el)->
    # requires the source to be on the same domain
    # or served with appropriate CORS headers.
    # can be overpassed by using a proxy: see {{proxySrc}}
    return $el.toDataURL()

  resizeDataUrl: (dataURL, maxSize, outputQuality=1)->
    new Promise (resolve, reject)->
      data = { original: {}, resized: {} }
      image = new Image()
      image.onload = (imageEvent)->
        canvas = document.createElement 'canvas'
        { width, height } = image
        saveDimensions data, 'original', width, height
        [ width, height ] = getResizedDimensions width, height, maxSize
        saveDimensions data, 'resized', width, height

        canvas.width = width
        canvas.height = height
        canvas.getContext('2d').drawImage image, 0, 0, width, height
        data.dataUrl = canvas.toDataURL 'image/jpeg', outputQuality
        resolve data

      image.onerror = reject

      image.src = dataURL


  canvasToBlob: (canvas)->
    if _.isCanvas canvas then canvas.toBlob()
    else throw new Error 'expected a canvas'

  dataUrlToBlob: (data)->
    if _.isDataUrl data then window.dataURLtoBlob data
    else throw new Error 'expected a dataURL'

  upload: (blobsData)->
    blobsData = _.forceArray blobsData
    formData = new FormData()

    i = 0
    for blobData in blobsData
      { blob, id } = blobData
      id or= "file-#{++i}"
      formData.append id, blob

    return new Promise (resolve, reject)->
      request = new XMLHttpRequest()
      request.onreadystatechange = ->
        if request.readyState is 4
          { status, statusText } = request
          if /^2/.test request.status.toString()
            resolve request.response
          else
            reject error_.new(statusText, status)
      request.onerror = reject
      request.ontimeout = reject

      request.open 'POST', app.API.upload.post
      request.responseType = 'json'
      request.send formData

  del: (imageUrlToDelete)->
    _.preq.post app.API.upload.del, {urls: imageUrlToDelete}
    .then _.Log('image del res')
    .catch _.Error('image del err')

  getNonResizedUrl: (url)->
    url.replace /\/img\/\d+x\d+\//, '/img/'

getResizedDimensions = (width, height, maxSize)->
  if width > height
    if width > maxSize
      height *= maxSize / width
      width = maxSize
  else
    if height > maxSize
      width *= maxSize / height
      height = maxSize
  return [ width, height ]

saveDimensions = (data, attribute, width, height)->
  data[attribute].width = width
  data[attribute].height = height

module.exports = handlers