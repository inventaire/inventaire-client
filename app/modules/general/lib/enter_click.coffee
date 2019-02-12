module.exports =
  input: (e)->
    # TODO: fix case where Firefox sends 'Process' (keyCode 229) keys instead of 'Enter'
    #       (or just wait for Firefox to fix it's own mess)
    if e.keyCode is 13 and $(e.currentTarget).val().length > 0
      row = $(e.currentTarget).parents('form, .inputGroup, .enterClickWrapper')[0]
      clickTarget $(row).find('.button, .tiny-button, .saveButton, .enterClickTarget')

  # Required:
  # textarea.ctrlEnterClick
  # a.sendMessage
  textarea: (e)->
    if e.keyCode is 13 and e.ctrlKey
      $el = $(e.currentTarget)
      if $el.val().length > 0
        clickTarget $el.parents('form').first().find '.sendMessage'

  button: (e)->
    if e.keyCode is 13 then $(e.currentTarget).trigger 'click'

clickTarget = ($target)->
  if $target.length > 0
    $target.trigger 'click'
    # _.log $target, 'enter click target'
  else
    _.error 'target not found'
