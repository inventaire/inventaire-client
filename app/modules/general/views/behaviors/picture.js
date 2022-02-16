import pictureTemplate from './templates/picture.hbs'
import Loading from '#behaviors/loading'

export default Marionette.View.extend({
  tagName: 'div',
  template: pictureTemplate,
  behaviors: {
    Loading,
  },

  initialize () {
    this.setCropper()
    // The model depends on the view to get the croppedDataUrl
    // so it must have a reference to it
    this.model.view = this
  },

  async setCropper () {
    await Promise.all([
      import('cropper'),
      import('cropper/dist/cropper.css'),
      this.model.waitForReady,
    ])
    this.ready = true
    this.lazyRender()
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
