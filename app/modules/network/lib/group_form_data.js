/* eslint-disable
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
export default {
  description (description) {
    return {
      id: 'description',
      placeholder: 'help other users to understand what this group is about',
      value: description
    }
  },

  searchability (active = true) {
    return {
      id: 'searchabilityToggler',
      checked: active,
      label: 'appear in search results'
    }
  }
}
