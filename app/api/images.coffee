{ action } = require('./endpoint')('images')

module.exports =
  upload: (ipfs)-> action 'upload', { ipfs }
  convertUrl: action 'convert-url'
  dataUrl: (url)-> action 'data-url', { url: encodeURIComponent(url) }
