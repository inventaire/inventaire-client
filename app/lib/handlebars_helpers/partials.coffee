behavior = (name)-> require "modules/general/views/behaviors/templates/#{name}"
check = behavior 'success_check'
tip = behavior 'tip'
SafeString = Handlebars.SafeString


module.exports =
  partial: (name, context, option) ->
    # parse the name to build the partial path
    parts = name.split ':'
    switch parts.length
      # ex: partial 'general:menu:feedbacks_news'
      when 3 then [module, subfolder, file] = parts
      # ex: partial 'user:persona_button'
      when 2 then [module, file] = parts
      # defaulting to general:partialName
      # ex: partial 'separator'
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