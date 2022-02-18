import { isUrl } from '#lib/boolean_tests'
import preq from '#lib/preq'
import ClaimsEditorCommons from './claims_editor_commons.js'
import forms_ from '#general/lib/forms'
import error_ from '#lib/error'
import files_ from '#lib/files'
import { getImageHashFromDataUrl } from '#lib/images'
import { startLoading, stopLoading } from '#general/plugins/behaviors'
import imageValueEditorTemplate from './templates/image_value_editor.hbs'
import AlertBox from '#behaviors/alert_box'
import Loading from '#behaviors/loading'

const urlInputSelector = '.imageUrl'
const imagePreviewSelector = '.image-preview'

export default ClaimsEditorCommons.extend({
  mainClassName: 'image-value-editor',
  template: imageValueEditorTemplate,

  behaviors: {
    AlertBox,
    Loading,
  },

  ui: {
    urlInput: urlInputSelector,
    uploadConfirmation: '.upload-confirmation',
    imagePreview: imagePreviewSelector
  },

  initialize () {
    this.initEditModeState()
    this.focusTarget = 'urlInput'
  },

  onRender () {
    this.focusOnRender()
  },

  events: {
    'click .edit, .displayModeData': 'showEditMode',
    'click .cancel': 'hideEditMode',
    'click .save': 'saveFromUrl',
    'click .delete': 'delete',
    // Not setting a particular selector so that
    // any keyup event on taezaehe element triggers the event
    keyup: 'onKeyUp',
    'change input[type=file]': 'getImageUrl',
    'click .validate-upload': 'uploadFileAndSave'
  },

  getImageUrl (e) {
    return files_.parseFileEventAsDataURL(e)
    .then(_.first)
    .then(this.showUploadConfirmation.bind(this))
  },

  showUploadConfirmation (dataUrl) {
    this.ui.imagePreview.html(`<img src="${dataUrl}">`)
    this.ui.uploadConfirmation.show()
  },

  saveFromUrl () {
    const url = this.ui.urlInput.val()

    if (url === this.model.get('value')) return this.hideEditMode()

    if (!isUrl(url)) {
      const err = error_.new('invalid URL', url)
      err.selector = urlInputSelector
      return forms_.alert(this, err)
    }

    startLoading.call(this, '.save')

    return preq.post(app.API.images.convertUrl, { url, container: 'entities' })
    .then(res => this._bareSave(res.hash))
    .catch(error_.Complete(urlInputSelector, false))
    .catch(forms_.catchAlert.bind(null, this))
    .finally(stopLoading.bind(this, '.save'))
  },

  uploadFileAndSave () {
    startLoading.call(this, '.validate-upload')
    const dataUrl = this.ui.imagePreview.find('img')[0]?.src
    return this.uploadDataUrl(dataUrl)
    .catch(error_.Complete(imagePreviewSelector, false))
    .catch(forms_.catchAlert.bind(null, this))
    .finally(stopLoading.bind(this, '.validate-upload'))
  },

  uploadDataUrl (dataUrl) {
    return getImageHashFromDataUrl('entities', dataUrl)
    .then(this._bareSave.bind(this))
  },

  // Triggered by Ctrl+Enter (behavior inherited from editor_commons)
  save () { return this.saveFromUrl() }
})
