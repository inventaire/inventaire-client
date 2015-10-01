module.exports =
  input: (e)->
    if e.keyCode is 13 and $(e.currentTarget).val().length > 0
      row = $(e.currentTarget).parents('form, .inputGroup')[0]
      $target =  $(row).find('.button, .tiny-button, .saveButton')
      if $target.length > 0
        $target.trigger 'click'
        # _.log $target, 'ui: enter-click'
      else
        _.error 'enterClick target not found'

  button: (e)->
    if e.keyCode is 13 then $(e.currentTarget).trigger 'click'
