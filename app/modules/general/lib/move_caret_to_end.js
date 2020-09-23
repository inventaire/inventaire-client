# inspired from http://stackoverflow.com/questions/4715762/javascript-move-caret-to-last-character/4716021#4716021
module.exports = (e)->
  el = e.target
  if _.isNumber(el.selectionStart)
    el.selectionStart = el.selectionEnd = el.value.length
  else if el.createTextRange?
    el.focus()
    range = el.createTextRange()
    range.collapse(false)
    range.select()
