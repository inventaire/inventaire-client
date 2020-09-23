/* eslint-disable
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
export default {
  setAttributes (attrs) {
    if (!attrs.extract) { attrs.extract = attrs.description }
    if (attrs.extract != null) {
      attrs.extractOverflow = attrs.extract.length > 600
    }
  }
}
