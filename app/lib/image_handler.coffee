module.exports =
  initialize: ->
    # Initialise resize library
    resize = new window.resize()
    resize.init()

    # Upload photo
    upload = (photo, callback) ->
      console.log "upload!!"
      formData = new FormData()
      formData.append("photo", photo)

      request = new XMLHttpRequest()
      request.onreadystatechange = ->
        callback request.response  if request.readyState is 4

      request.open "POST", "/api/upload"
      request.responseType = "json"
      request.send formData

    document.querySelector("input[type=file]").addEventListener "change", (event) ->
      event.preventDefault()
      files = event.target.files
      for i of files
        return false  if typeof files[i] isnt "object"
        (->
          initialSize = files[i].size
          resize.photo files[i], 1200, "file", (resizedFile) ->
            resizedSize = resizedFile.size
            upload resizedFile, (response) ->
              console.log response.url

            # This is not used in the demo, but an example which returns a data URL so yan can show the user a thumbnail before uploading th image.
            resize.photo resizedFile, 600, "dataURL", (thumbnail) ->
              console.log "Display the thumbnail to the user: ", thumbnail
              $('input[type=file]').parent().append("<img src='#{thumbnail}'>")
        )()
