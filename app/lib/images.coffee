error_ = require 'lib/error'
dataURLtoBlob = require 'blueimp-canvas-to-blob'

images_ =
  addDataUrlToArray: (file, array, event)->
    resize.photo file, 600, 'dataURL', (data)->
      array.unshift data
      if array.trigger? and event? then array.trigger event

  getUrlDataUrl: (url)->
    _.preq.get app.API.images.dataUrl(url)
    .get 'data-url'

  getElementDataUrl: ($el)->
    # requires the source to be on the same domain
    # or served with appropriate CORS headers.
    # can be overpassed by using a proxy: see {{proxySrc}}
    return $el.toDataURL()

  resizeDataUrl: (dataURL, maxSize, outputQuality = 1)->
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

      # This exact message is expected by the Img model
      image.onerror = (e)-> reject new Error('invalid image')

      image.src = dataURL

  dataUrlToBlob: (data)->
    if _.isDataUrl data then dataURLtoBlob data
    else throw new Error 'expected a dataURL'

  upload: (container, blobsData, hash = false)->
    blobsData = _.forceArray blobsData
    formData = new FormData()

    i = 0
    for blobData in blobsData
      { blob, id } = blobData
      unless blob? then throw error_.new 'missing blob', blobData
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

      request.open 'POST', app.API.images.upload(container, hash)
      request.responseType = 'json'
      request.send formData

  getImageHashFromDataUrl: (container, dataUrl)->
    unless _.isDataUrl dataUrl then throw error_.new 'invalid image', dataUrl
    return images_.upload container, { blob: images_.dataUrlToBlob(dataUrl) }, true
    .then (res)-> _.values(res)[0].split('/').slice(-1)[0]

  getNonResizedUrl: (url)-> url.replace /\/img\/users\/\d+x\d+\//, '/img/'

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

module.exports = images_
