regex_ = sharedLib 'regex'
PicturePicker = require 'modules/general/views/behaviors/picture_picker'
error_ = require 'lib/error'

module.exports = ->
  app.layout.modal.show new PicturePicker
    pictures: app.user.get 'picture'
    save: savePicture
    crop: true
    limit: 1

savePicture = (pictures)->
  picture = pictures[0]
  _.log picture, 'picture'
  unless _.isLocalImg picture
    message = 'couldnt save picture: requires a local image url'
    throw error_.new message, pictures

  app.request 'user:update',
    attribute: 'picture'
    value: picture
    selector: '.changePicture .loading'
