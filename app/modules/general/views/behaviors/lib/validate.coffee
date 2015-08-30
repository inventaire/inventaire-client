imageHandler = require 'lib/image_handler'

# stinky code: extracted to be refactored
module.exports =
  validate: ->
    urls = @_getUrls()
    states = @_getStates()

    if urls.length isnt states.length
      throw new Error 'urls and associated states not matching'

    i = 0
    toDelete = []
    toKeep = []

    while i < urls.length
      # console.log i, 'i'
      unless states[i]?
        console.error 'missing state', states[i], states, i
      else
        if 'deleted' in states[i]
          toDelete.push urls[i]
        else if ('selected' in states[i]) and not @selected?
          @selected = urls[i]
        else
          toKeep.push urls[i]
      i += 1

    console.log 'toDelete', toDelete, 'toKeep', toKeep

    @deletePictures toDelete

    # adding the selected url at the first place
    # in the list of images to keep
    if @selected? then toKeep.unshift @selected

    _.log toKeep, 'toKeep'

    picturesToUpload = toKeep.filter _.isDataUrl
    _.log picturesToUpload, 'picturesToUpload'

    unless picturesToUpload?.length > 0
      @close()
      @options.save toKeep
      return

    @$el.trigger 'loading'
    imageHandler.upload picturesToUpload
    .then @_afterUpload.bind(@, toKeep)
    .catch _.Error('picturesToUpload err')

  _getUrls: ->
    imgs = _.toArray @ui.availablePicturesImgs
    urls = imgs.map _.property('src')
    return _.log urls, 'urls'

  _getStates: ->
    figures = _.toArray @ui.availablePictures
    states = figures.map (fig)-> _.toArray fig.classList
    return _.log states, 'states'

  _afterUpload: (toKeep, urls)->
    updatedPictures = @_getUpdatedPictures toKeep, urls
    @close()
    @options.save updatedPictures

  _getUpdatedPictures: (toKeep, urls)->
    updatedPictures = toKeep.map (pic)->
      # replacing the dataUrl by the http url returned from the server
      # relying on the hypothesis that the order is respected
      if _.isDataUrl pic then return urls.shift()
      else return pic

    _.log updatedPictures, 'updatedPictures'