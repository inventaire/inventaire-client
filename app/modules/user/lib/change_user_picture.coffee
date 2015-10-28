regex_ = sharedLib 'regex'
PicturePicker = require 'modules/general/views/behaviors/picture_picker'

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
    throw new Error 'couldnt save picture: requires a local image url'

  app.request 'user:update',
    attribute: 'picture'
    value: picture
    selector: '#changePicture'
