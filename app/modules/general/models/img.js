import images_ from 'lib/images';
const { maxSize } = CONFIG.images;
const container = 'users';

// named Img and not Image to avoid overwritting window.Image
export default Backbone.NestedModel.extend({
  initialize() {
    const { url, dataUrl } = this.toJSON();

    const input = url || dataUrl;
    if (input == null) { throw new Error('at least one input attribute is required'); }

    if (url != null) { this.initFromUrl(url); }
    if (dataUrl != null) { this.initDataUrl(dataUrl); }

    return this.crop = this.get('crop');
  },

  initFromUrl(url){
    return this.waitForReady = this.setDataUrlFromUrl(url)
      .then(this.resize.bind(this))
      .catch(_.Error('initFromUrl err'));
  },

  initDataUrl(dataUrl){
    this.set('originalDataUrl', dataUrl);
    return this.waitForReady = this.resize();
  },

  setDataUrlFromUrl(url){
    return images_.getUrlDataUrl(url)
    .then(this.set.bind(this, 'originalDataUrl'));
  },

  resize() {
    const dataUrl = this.get('originalDataUrl');
    return images_.resizeDataUrl(dataUrl, maxSize)
    .then(this.set.bind(this))
    .catch(err=> {
      if (err.message === 'invalid image') { return this.collection.invalidImage(this, err);
      } else { throw err; }
    });
  },

  select() { return this.set('selected', true); },

  setCroppedDataUrl() {
    if (this.view != null) {
      const croppedData = this.view.getCroppedDataUrl();
      const { dataUrl, width, height } = croppedData;
      return this.set({
        croppedDataUrl: dataUrl,
        cropped: {
          width,
          height
        }
      });
    }
  },

  getFinalDataUrl() {
    return this.get('croppedDataUrl') || this.get('dataUrl');
  },

  imageHasChanged() {
    const finalAttribute = this.crop ? 'cropped' : 'resized';

    const widthChange = this._areDifferent(finalAttribute, 'original', 'width');
    const heightChange = this._areDifferent(finalAttribute, 'original', 'height');
    return _.log(widthChange || heightChange, 'image changed?');
  },

  _areDifferent(a, b, value){
    return this.get(a)[value] !== this.get(b)[value];
  },

  getFinalUrl() {
    if (this.crop) { this.setCroppedDataUrl(); }
    // testing the original url existance as it imageHasChanged alone
    // wouldn't detect that a new image from file
    const originalUrl = this.get('url');
    if ((originalUrl != null) && !this.imageHasChanged()) { return Promise.resolve(originalUrl); }

    return images_.upload(container, {
      blob: images_.dataUrlToBlob(this.getFinalDataUrl()),
      id: this.cid
    }).get(this.cid)
    .then(_.Log('url?'));
  }
});
