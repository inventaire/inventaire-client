/* eslint-disable
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
export default {
  pluralize (type) {
    if (type.slice(-1)[0] !== 's') { type += 's' }
    return type
  }
}
