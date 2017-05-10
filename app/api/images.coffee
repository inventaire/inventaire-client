{ action } = require('./endpoint')('images')

module.exports =
  upload: action 'upload'
  convertUrl: action 'convert-url'
