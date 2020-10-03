import cropper from 'modules/general/lib/cropper'

export default Marionette.ItemView.extend({
  tagName: 'div',
  template: require('./templates/picture.hbs'),
  behaviors: {
    Loading: {}
  },

  initialize () {
    cropper.get()
    .then(() => this.model.waitForReady)
    .then(() => { this.ready = true })
    .then(this.lazyRender.bind(this))

    // the model depends on the view to get the croppedDataUrl
    // so it must have a reference to it
    this.model.view = this
  },

  serializeData () {
    return _.extend(this.model.toJSON(), {
      classes: this.getClasses(),
      ready: this.ready
    })
  },

  modelEvents: {
    'change:selected': 'lazyRender'
  },

  ui: {
    figure: 'figure',
    img: '.original'
  },

  getClasses () {
    if (this.model.get('selected')) {
      return 'selected'
    } else {
      return ''
    }
  },

  onRender () {
    if (this.model.get('crop')) {
      if (this.ready && this.model.get('selected')) {
        this.setTimeout(this.initCropper.bind(this), 200)
      }
    }
  },

  initCropper () {
    // don't use a ui object to get the img
    // as the .selected class is added and removed
    // while the ui object is not being updated
    this.ui.img.cropper({
      aspectRatio: 1 / 1,
      autoCropArea: 1,
      minCropBoxWidth: 300,
      minCropBoxHeight: 300
    })
  },

  getCroppedDataUrl (outputQuality = 1) {
    const data = this.ui.img.cropper('getData')
    const canvas = this.ui.img.cropper('getCroppedCanvas')
    data.dataUrl = canvas.toDataURL('image/jpeg', outputQuality)
    return data
  }
})
