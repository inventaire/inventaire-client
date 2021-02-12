import log_ from 'lib/loggers'
import { getUrlDataUrl, resizeDataUrl, upload, dataUrlToBlob } from 'lib/images'
const maxSize = 1600
const container = 'users'

// named Img and not Image to avoid overwritting window.Image
export default Backbone.NestedModel.extend({
  initialize () {
    const { url, dataUrl } = this.toJSON()

    const input = url || dataUrl
    if (input == null) throw new Error('at least one input attribute is required')

    if (url != null) this.initFromUrl(url)
    else if (dataUrl != null) this.initDataUrl(dataUrl)

    this.crop = this.get('crop')
  },

  initFromUrl (url) {
    this.waitForReady = this.setDataUrlFromUrl(url)
      .then(this.resize.bind(this))
      .catch(log_.Error('initFromUrl err'))
  },

  initDataUrl (dataUrl) {
    this.set('originalDataUrl', dataUrl)
    this.waitForReady = this.resize()
  },

  setDataUrlFromUrl (url) {
    return getUrlDataUrl(url)
    .then(this.set.bind(this, 'originalDataUrl'))
  },

  resize () {
    const dataUrl = this.get('originalDataUrl')
    return resizeDataUrl(dataUrl, maxSize)
    .then(this.set.bind(this))
    .catch(err => {
      if (err.message === 'invalid image') {
        return this.collection.invalidImage(this, err)
      } else {
        throw err
      }
    })
  },

  select () { this.set('selected', true) },

  setCroppedDataUrl () {
    if (this.view != null) {
      const croppedData = this.view.getCroppedDataUrl()
      const { dataUrl, width, height } = croppedData
      this.set({
        croppedDataUrl: dataUrl,
        cropped: {
          width,
          height
        }
      })
    }
  },

  getFinalDataUrl () {
    return this.get('croppedDataUrl') || this.get('dataUrl')
  },

  imageHasChanged () {
    const finalAttribute = this.crop ? 'cropped' : 'resized'

    const widthChange = this._areDifferent(finalAttribute, 'original', 'width')
    const heightChange = this._areDifferent(finalAttribute, 'original', 'height')
    return log_.info(widthChange || heightChange, 'image changed?')
  },

  _areDifferent (a, b, value) {
    return this.get(a)[value] !== this.get(b)[value]
  },

  async getFinalUrl () {
    if (this.crop) this.setCroppedDataUrl()
    // testing the original url existance as it imageHasChanged alone
    // wouldn't detect that a new image from file
    const originalUrl = this.get('url')
    if ((originalUrl != null) && !this.imageHasChanged()) return originalUrl

    const urls = await upload(container, {
      blob: dataUrlToBlob(this.getFinalDataUrl()),
      id: this.cid
    })
    const url = urls[this.cid]
    log_.info(url, 'url')
    return url
  }
})
