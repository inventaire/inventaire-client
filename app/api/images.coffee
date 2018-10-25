{ action } = require('./endpoint')('images')

module.exports =
  upload: (hash)-> action 'upload', { hash }
  convertUrl: action 'convert-url'
  dataUrl: (url)-> action 'data-url', { url: encodeURIComponent(url) }
