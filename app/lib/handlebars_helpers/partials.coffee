behavior = (name)-> require "modules/general/views/behaviors/templates/#{name}"
check = behavior 'success_check'
tip = behavior 'tip'
SafeString = Handlebars.SafeString


module.exports =
  partial: (name, context, option) ->
    parts = name.split ':'
    switch parts.length
      when 3 then [module, subfolder, file] = parts
      when 2 then [module, file] = parts
      # defaulting to general:partialName
      when 1 then [module, file] = ['general', name]

    if subfolder? then path = "modules/#{module}/views/#{subfolder}/templates/#{file}"
    else path = "modules/#{module}/views/templates/#{file}"

    template = require path
    partial = new SafeString template(context)
    switch option
      when 'check' then partial = new SafeString check(partial)
    return partial

  tip: (text, position)->
    context =
      text: _.i18n text
      position: position or 'rigth'
    new SafeString tip(context)