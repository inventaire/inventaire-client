/* eslint-disable
    import/no-duplicates,
    no-undef,
    no-unused-vars,
    no-var,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import regex_ from 'lib/regex'
import PicturePicker from 'modules/general/views/behaviors/picture_picker'
import error_ from 'lib/error'

export default () => app.layout.modal.show(new PicturePicker({
  context: 'user',
  pictures: app.user.get('picture'),
  save: savePicture,
  delete: deletePicture,
  crop: true,
  limit: 1
})
)

const selector = '.changePicture .loading'

var savePicture = function (pictures) {
  const picture = pictures[0]
  _.log(picture, 'picture')
  if (!_.isUserImg(picture)) {
    const message = 'couldnt save picture: requires a local user image url'
    throw error_.new(message, pictures)
  }

  return app.request('user:update', {
    attribute: 'picture',
    value: picture,
    selector
  }
  )
}

var deletePicture = () => app.request('user:update', {
  attribute: 'picture',
  value: null,
  selector
}
)
