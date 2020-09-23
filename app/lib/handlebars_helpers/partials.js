const behavior = name => require(`modules/general/views/behaviors/templates/${name}`)
const check = behavior('success_check')
const { SafeString } = Handlebars

export default {
  partial (name, context, option) {
    // parse the name to build the partial path
    let file, module, path, subfolder
    const parts = name.split(':')
    switch (parts.length) {
    // ex: partial 'general:menu:feedback_news'
    case 3: [ module, subfolder, file ] = Array.from(parts); break
      // ex: partial 'user:password_input'
    case 2: [ module, file ] = Array.from(parts); break
      // defaulting to general:partialName
      // ex: partial 'separator'
    case 1: [ module, file ] = Array.from([ 'general', name ]); break
    }

    if (subfolder != null) {
      path = `modules/${module}/views/${subfolder}/templates/${file}`
    } else { path = `modules/${module}/views/templates/${file}` }

    const template = require(path)
    let partial = new SafeString(template(context))
    switch (option) {
    case 'check': partial = new SafeString(check(partial)); break
    }
    return partial
  }
}
