module.exports = ->
  picturePicker = new app.View.Behaviors.PicturePicker
    pictures: app.user.get('picture')
    limit: 1
    save: savePicture
  app.layout.modal.show picturePicker

savePicture = (pictures)->
  picture = pictures[0]
  unless _.isUrl picture
    throw new Error 'couldnt save picture: requires a url'

  app.request 'user:update',
    attribute: 'picture'
    value: picture
    selector: '#changePicture'