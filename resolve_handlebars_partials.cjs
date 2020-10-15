const { resolve } = require('path')

module.exports = (partial, callback) => {
  const parts = partial.split(':')
  let file, module, subfolder
  if (parts.length === 3) {
    // ex: partial 'general:menu:feedback_news'
    [ module, subfolder, file ] = parts
  } else if (parts.length === 2) {
    // ex: partial 'user:password_input'
    [ module, file ] = parts
  } else if (parts.length === 1) {
    // defaulting to general:partialName
    // ex: partial 'separator'
    [ module, file ] = [ 'general', partial ]
  }

  let path
  if (subfolder != null) {
    path = `./app/modules/${module}/views/${subfolder}/templates/${file}.hbs`
  } else {
    path = `./app/modules/${module}/views/templates/${file}.hbs`
  }

  const resolved = resolve(__dirname, path)
  callback(null, resolved)
}
