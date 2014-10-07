# largely inspired from http://demo.joelvardy.com/uploads/

module.exports = ->
  @init = (outputQuality) ->
    @outputQuality = outputQuality or 0.8

  @photo = (file, maxSize, outputType, callback) ->
    reader = new FileReader()
    reader.onload = (readerEvent) =>
      @resize readerEvent.target.result, maxSize, outputType, callback

    reader.readAsDataURL file

  @resize = (dataURL, maxSize, outputType, callback) ->
    image = new Image()
    image.onload = (imageEvent) =>
      # Resize image
      canvas = document.createElement('canvas')
      width = image.width
      height = image.height
      if width > height
        if width > maxSize
          height *= maxSize / width
          width = maxSize
      else
        if height > maxSize
          width *= maxSize / height
          height = maxSize
      canvas.width = width
      canvas.height = height
      canvas.getContext('2d').drawImage image, 0, 0, width, height
      @output canvas, outputType, callback

    image.src = dataURL

  @output = (canvas, outputType, callback) ->
    switch outputType
      when 'file'
        cb = (blob)-> callback blob
        canvas.toBlob cb, 'image/jpeg', @outputQuality
      when 'dataURL'
        callback canvas.toDataURL('image/jpeg', @outputQuality)
      else console.error 'unknown output: pick either file or dataURL'
  return