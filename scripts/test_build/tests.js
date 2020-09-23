/* eslint-disable
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
export const welcome = {
  path: 'welcome',
  tests: {
    expectedContent (html) {
      const re = new RegExp('id="lastPublicBooks"')
      if (!re.test(html)) {
        throw new Error('missing element')
      }
    },

    built (html) {
      const re = new RegExp('<!-- PIWIK -->')
      if (re.test(html)) {
        throw new Error("html isn't in built state")
      }
    },

    minified (html) {
      const re = new RegExp('<meta charset="utf-8"><meta')
      if (!re.test(html)) {
        throw new Error("html isn't minified")
      }
    }
  }
}
