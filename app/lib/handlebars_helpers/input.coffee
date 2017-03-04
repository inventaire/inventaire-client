behavior = (name)-> require "modules/general/views/behaviors/templates/#{name}"
check = behavior 'success_check'
input = behavior 'input'
textarea = behavior 'textarea'
{ SafeString } = Handlebars

# data =
#   nameBase: {String}
#   id: {String} *
#   special: {Boolean}
#   field:
#     id: {String} *
#     name: {String} *
#     value: {String}
#     type: {String}
#     placeholder: {String} *
#     dotdotdot: {String}
#     classes: {String}
#   button:
#     id: {String} *
#     text: {String} *
#     icon: {String} (replaces button.text)
#     classes: {String}
#
# (*) guess from nameBase

module.exports =
  input: (data, options)->
    unless data?
      _.log arguments, 'input arguments @err'
      throw new Error 'no data'

    # default data, overridden by arguments
    field =
      type: 'text'
      dotdotdot: '...'
    button =
      classes: 'success postfix'

    name = data.nameBase
    if name?
      field.id = name + 'Field'
      field.name = name
      button.id = name + 'Button'
      button.text = name

    if data.button?.icon?
      icon = _.icon data.button.icon
      if data.button.text?
        data.button.text = "#{icon}<span>#{data.button.text }</span>"
      else
        data.button.text = icon

    # data overriding happens here
    data =
      id: "#{name}Group"
      field: _.extend field, data.field
      button: _.extend button, data.button

    # default value defined after all the rest
    # to avoid requesting unnecessary strings to i18n
    # (which would result in a report for a missing i18n key)
    data.field.placeholder ?= _.i18n name

    if data.special
      data.special = 'autocorrect="off" autocapitalize="off"'

    applyOptions input(data), options

  disableAuto: -> 'autocorrect="off" autocapitalize="off"'

  textarea: (data, options)->
    unless data?
      _.log arguments, 'textarea arguments err'
      throw new Error 'no data'
    applyOptions textarea(data), options

applyOptions = (html, options)->
  html = if options is 'check' then check html else html
  return new SafeString html
