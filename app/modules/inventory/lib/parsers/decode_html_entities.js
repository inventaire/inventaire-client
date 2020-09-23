/* eslint-disable
    no-undef,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
let element = null

// Adapted from https://stackoverflow.com/a/9609450/3324977
export default function (str) {
  // Ignore this lib in test environments
  if (document.createElement == null) { return str }

  if (!_.isNonEmptyString(str)) { return str }

  if (!element) { element = document.createElement('div') }
  str = str
    // strip script/html tags
    .replace(/<script[^>]*>([\S\s]*?)<\/script>/gmi, '')
    .replace(/<\/?\w(?:[^"'>]|"[^"]*"|'[^']*')*>/gmi, '')
  element.innerHTML = str
  str = element.textContent
  element.textContent = ''
  return str
};
