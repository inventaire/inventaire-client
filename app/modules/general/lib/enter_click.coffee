module.exports = (e)->
  if e.keyCode is 13 and $(e.currentTarget).val().length > 0
    row = $(e.currentTarget).parents('form')[0]
    $target =  $(row).find('.button, .tiny-button, .saveButton')
    if $target.length > 0
      $target.trigger 'click'
      _.log 'ui: enter-click'
    else
      _.error('enterClick target not found')