import Imgs from 'modules/general/collections/imgs'
import images_ from 'lib/images'
import files_ from 'lib/files'
import forms_ from 'modules/general/lib/forms'
import error_ from 'lib/error'
import behaviorsPlugin from 'modules/general/plugins/behaviors'
import cropper from 'modules/general/lib/cropper'
import getActionKey from 'lib/get_action_key'

export default Marionette.CompositeView.extend({
  className () {
    const { limit } = this.options
    return `picture-picker limit-${limit}`
  },

  template: require('./templates/picture_picker'),
  childViewContainer: '#availablePictures',
  childView: require('./picture'),

  behaviors: {
    General: {},
    AlertBox: {},
    SuccessCheck: {},
    Loading: {},
    PreventDefault: {}
  },

  initialize () {
    ({ context: this.context } = this.options)
    this.limit = this.options.limit || 1
    const pictures = _.forceArray(this.options.pictures)
    cropper.prepare()
    const collectionData = pictures.map(getImgData.bind(null, this.options.crop))
    this.collection = new Imgs(collectionData)
    this.listenTo(this.collection, 'invalid:image', this.onInvalidImage.bind(this))
  },

  serializeData () {
    return {
      urlInput: this.urlInputData(),
      userContext: this.context === 'user'
    }
  },

  urlInputData () {
    return {
      nameBase: 'url',
      field: {
        type: 'url',
        placeholder: _.i18n('enter an image url')
      },
      button: {
        text: _.i18n('go get it!')
      },
      allowMultiple: this.limit > 1
    }
  },

  onShow () {
    app.execute('modal:open', 'large', this.options.focus)
    this.selectFirst()
    this.ui.urlInput.focus()
  },

  ui: {
    urlInput: '#urlField'
  },

  events: {
    'click #cancel': 'close',
    'click #delete': 'delete',
    'click #validate': 'validate',
    'click #urlButton': 'fetchUrlPicture',
    'click .fetchGravatar': 'fetchGravatar',
    'change input[type=file]': 'getFilesPictures',
    'keyup input[type=file]': 'preventUnwantedModalClose'
  },

  selectFirst () {
    return this.collection.models[0]?.select()
  },

  delete () {
    this.options.delete()
    return this.close()
  },

  validate () {
    behaviorsPlugin.startLoading.call(this, {
      selector: '#validate',
      // The upload might take longer than the default 30 secondes,
      // so here is a very permissive 10 minutes, for the case a user
      // uploads a big picture with a slow connexion
      timeout: 600
    })

    return this.getFinalUrls()
    .catch(error_.Complete('.alertBox'))
    .then(_.Log('final urls'))
    .then(this._saveAndClose.bind(this))
    .catch(forms_.catchAlert.bind(null, this))
  },

  getFinalUrls () {
    let selectedModels = this.collection.models.filter(isSelectedModel)
    selectedModels = selectedModels.slice(0, this.limit)
    return Promise.all(_.invoke(selectedModels, 'getFinalUrl'))
  },

  _saveAndClose (urls) {
    if (urls.length > 0) { this.options.save(urls) }
    return this.close()
  },

  fetchUrlPicture () {
    let url = this.ui.urlInput.val()

    // use the full definition image:
    // - allow better resolution if the url size was small
    // - allow to host the image only once has the image hash will be the same
    url = images_.getNonResizedUrl(url)

    return Promise.try(validateUrlInput.bind(null, url))
    .then(images_.getUrlDataUrl.bind(null, url))
    .then(this._addToPictures.bind(this))
    .catch(error_.Complete('#urlField'))
    .catch(forms_.catchAlert.bind(null, this))
  },

  fetchGravatar () {
    return images_.getUserGravatarUrl()
    .then(url => {
      this.ui.urlInput.val(url)
      return this.fetchUrlPicture()
    })
    .catch(error_.Complete('#urlField'))
    .catch(forms_.catchAlert.bind(null, this))
  },

  getFilesPictures (e) {
    // Hide any remaing alert box
    this.$el.trigger('hideAlertBox')

    return files_.parseFileEventAsDataURL(e)
    .then(_.Log('filesDataUrl'))
    .map(this._addToPictures.bind(this))
  },

  _addToPictures (dataUrl) {
    if (this.limit === 1) { this._unselectAll() }
    return this._addDataUrlToCollection(dataUrl)
  },

  _unselectAll (dataUrl) {
    return this.collection.invoke('set', 'selected', false)
  },

  _addDataUrlToCollection (dataUrl) {
    return this.collection.add({
      dataUrl,
      selected: true,
      crop: this.options.crop
    })
  },

  onInvalidImage (err) {
    err.selector = '#fileField'
    return forms_.alert(this, err)
  },

  close () { app.execute('modal:close') },

  preventUnwantedModalClose (e) {
    const key = getActionKey(e)
    if (key === 'esc') {
      // prevent that closing the file picker with ESC to trigger modal:close
      _.log('stopped ESC propagation')
      return e.stopPropagation()
    }
  }
})

const isSelectedModel = model => model.get('selected')

const validateUrlInput = function (url) {
  if (!_.isUrl(url)) {
    return forms_.throwError('invalid url', '#urlField', arguments)
  }
}

const getImgData = (crop, url) => ({
  url,
  crop
})
