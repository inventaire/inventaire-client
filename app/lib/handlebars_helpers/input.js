const behavior = name => require(`modules/general/views/behaviors/templates/${name}`)
const check = behavior('success_check')
const input = behavior('input')
const textarea = behavior('textarea')
const { SafeString } = Handlebars

// data =
//   nameBase: {String}
//   id: {String} *
//   special: {Boolean}
//   field:
//     id: {String} *
//     name: {String} *
//     value: {String}
//     type: {String}
//     placeholder: {String} *
//     dotdotdot: {String}
//     classes: {String}
//   button:
//     id: {String} *
//     text: {String} *
//     icon: {String} (replaces button.text)
//     classes: {String}
//
// (*) guess from nameBase

export default {
  input (data, options) {
    if (data == null) {
      _.log(arguments, 'input arguments @err')
      throw new Error('no data')
    }

    // default data, overridden by arguments
    const field = {
      type: 'text',
      dotdotdot: '...'
    }
    const button =
      { classes: 'success postfix' }

    const name = data.nameBase
    if (name != null) {
      field.id = name + 'Field'
      field.name = name
      button.id = name + 'Button'
      button.text = name
    }

    if (data.button?.icon != null) {
      const icon = _.icon(data.button.icon)
      if (data.button.text != null) {
        data.button.text = `${icon}<span>${data.button.text}</span>`
      } else {
        data.button.text = icon
      }
    }

    const rawData = data
    data = {
      id: `${name}Group`,
      field: _.extend(field, data.field),
      button: _.extend(button, data.button)
    }

    // default value defined after all the rest
    // to avoid requesting unnecessary strings to i18n
    // (which would result in a report for a missing i18n key)
    if (data.field.placeholder == null) { data.field.placeholder = _.i18n(name) }

    if (rawData.special) {
      data.special = 'autocomplete="off" autocorrect="off" autocapitalize="off"'
    }

    return applyOptions(input(data), options)
  },

  disableAuto () { return 'autocorrect="off" autocapitalize="off"' },

  textarea (data, options) {
    if (data == null) {
      _.log(arguments, 'textarea arguments err')
      throw new Error('no data')
    }
    return applyOptions(textarea(data), options)
  }
}

var applyOptions = function (html, options) {
  html = options === 'check' ? check(html) : html
  return new SafeString(html)
}
