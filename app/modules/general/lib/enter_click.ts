import log_ from '#lib/loggers'

export default {
  input (e) {
    // TODO: fix case where Firefox sends 'Process' (keyCode 229) keys instead of 'Enter'
    //       (or just wait for Firefox to fix it's own mess)
    if ((e.keyCode === 13) && ($(e.currentTarget).val().length > 0)) {
      const row = $(e.currentTarget).parents('form, .inputGroup, .enterClickWrapper')[0]
      return clickTarget($(row).find('.button, .tiny-button, .saveButton, .enterClickTarget'))
    }
  },

  // Required:
  // textarea.ctrlEnterClick
  // a.sendMessage
  textarea (e) {
    if ((e.keyCode === 13) && e.ctrlKey) {
      const $el = $(e.currentTarget)
      if ($el.val().length > 0) {
        return clickTarget($el.parents('form, .ctrlEnterClickWrapper').first().find('.sendMessage, .save'))
      }
    }
  },

  button (e) {
    if (e.keyCode === 13) $(e.currentTarget).trigger('click')
  }
}

const clickTarget = function ($target) {
  if ($target.length > 0) {
    $target.trigger('click')
  } else {
    log_.error('target not found')
  }
}
