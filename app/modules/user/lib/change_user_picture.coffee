regex_ = require 'lib/regex'
PicturePicker = require 'modules/general/views/behaviors/picture_picker'
error_ = require 'lib/error'

module.exports = ->
  app.layout.modal.show new PicturePicker
    pictures: app.user.get 'picture'
    save: savePicture
    delete: deletePicture
    crop: true
    limit: 1

selector = '.changePicture .loading'

savePicture = (pictures)->
  picture = pictures[0]
  _.log picture, 'picture'
  unless _.isUserImg picture
    message = 'couldnt save picture: requires a local user image url'
    throw error_.new message, pictures

  app.request 'user:update',
    attribute: 'picture'
    value: picture
    selector: selector

deletePicture = ->
  app.request 'user:update',
    attribute: 'picture'
    value: null
    selector: selector
