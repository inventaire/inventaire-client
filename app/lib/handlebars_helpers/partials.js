import { SafeString } from 'handlebars'
import check from 'modules/general/views/behaviors/templates/success_check.hbs'

// Hack: pre-import all partials to force Parcel to include them in the bundle
// otherwise we get "Cannot resolve dependency" errors
import 'modules/general/views/templates/app_layout.hbs'
import 'modules/general/views/templates/back.hbs'
import 'modules/general/views/templates/call_to_connection.hbs'
import 'modules/general/views/templates/checkbox.hbs'
import 'modules/general/views/templates/common_separator.hbs'
import 'modules/general/views/templates/confirmation_modal.hbs'
import 'modules/general/views/templates/ctrl_enter_click_tip.hbs'
import 'modules/general/views/templates/donate_menu.hbs'
import 'modules/general/views/templates/error.hbs'
import 'modules/general/views/templates/feedback_menu.hbs'
import 'modules/general/views/templates/feedbacks_menu.hbs'
import 'modules/general/views/templates/filter.hbs'
import 'modules/general/views/templates/global_menu.hbs'
import 'modules/general/views/templates/horizontal_separator.hbs'
import 'modules/general/views/templates/icon_with_counter.hbs'
import 'modules/general/views/templates/loader.hbs'
import 'modules/general/views/templates/new_message.hbs'
import 'modules/general/views/templates/save_cancel.hbs'
import 'modules/general/views/templates/text_field.hbs'
import 'modules/general/views/templates/toggler.hbs'
import 'modules/general/views/templates/toggle_wrap.hbs'
import 'modules/general/views/templates/token.hbs'
import 'modules/general/views/templates/top_bar_buttons.hbs'
import 'modules/general/views/templates/top_bar.hbs'
import 'modules/general/views/templates/top_bar_language_picker.hbs'
import 'modules/general/views/templates/vertical_separator.hbs'

export default {
  partial (name, context, option) {
    // parse the name to build the partial path
    let file, module, path, subfolder
    const parts = name.split(':')
    switch (parts.length) {
    // ex: partial 'general:menu:feedback_news'
    case 3: [ module, subfolder, file ] = parts; break
      // ex: partial 'user:password_input'
    case 2: [ module, file ] = parts; break
      // defaulting to general:partialName
      // ex: partial 'separator'
    case 1: [ module, file ] = [ 'general', name ]; break
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
