import { SafeString } from 'handlebars'
import check from 'modules/general/views/behaviors/templates/success_check.hbs'

export default {
  partial (name, context, option) {
    // parse the name to build the partial path
    let file, module, path, subfolder
    const parts = name.split(':')
    if (parts.length === 3) {
      // ex: partial 'general:menu:feedback_news'
      [ module, subfolder, file ] = parts
    } else if (parts.length === 2) {
      // ex: partial 'user:password_input'
      [ module, file ] = parts
    } else if (parts.length === 1) {
      // defaulting to general:partialName
      // ex: partial 'separator'
      [ module, file ] = [ 'general', name ]
    }

    if (subfolder != null) {
      path = `modules/${module}/views/${subfolder}/templates/${file}.hbs`
    } else {
      path = `modules/${module}/views/templates/${file}.hbs`
    }

    const template = require(path)
    let partial = new SafeString(template(context))
    if (option === 'check') partial = new SafeString(check(partial))
    return partial
  }
}
