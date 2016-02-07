module.exports =
  input: (e)->
    if e.keyCode is 13 and $(e.currentTarget).val().length > 0
      row = $(e.currentTarget).parents('form, .inputGroup')[0]
      clickTarget $(row).find('.button, .tiny-button, .saveButton')

  # Required:
  # textarea.ctrlEnterClick
  # a.sendMessage, a.postComment
  textarea: (e)->
    if e.keyCode is 13 and e.ctrlKey
      $el = $(e.currentTarget)
      if $el.val().length > 0
        clickTarget $el.parents('form').first().find '.sendMessage, .postComment'

  button: (e)->
    if e.keyCode is 13 then $(e.currentTarget).trigger 'click'


clickTarget = ($target)->
  if $target.length > 0
    $target.trigger 'click'
    # _.log $target, 'enter click target'
  else
    _.error 'target not found'
