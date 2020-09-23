/* eslint-disable
    no-return-assign,
    no-undef,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
// inspired from http://stackoverflow.com/questions/4715762/javascript-move-caret-to-last-character/4716021#4716021
export default function (e) {
  const el = e.target
  if (_.isNumber(el.selectionStart)) {
    return el.selectionStart = (el.selectionEnd = el.value.length)
  } else if (el.createTextRange != null) {
    el.focus()
    const range = el.createTextRange()
    range.collapse(false)
    return range.select()
  }
};
