{ action } = require('./endpoint')('images')

module.exports =
  upload: (container, hash)-> action 'upload', { container, hash }
  convertUrl: action 'convert-url'
  dataUrl: (url)-> action 'data-url', { url: encodeURIComponent(url) }
