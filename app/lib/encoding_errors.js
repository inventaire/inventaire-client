/* eslint-disable
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
const encodingsErrors = {
  // characters showing that this encoding should be used instead
  'Ã©': 'utf-8',
  'Ã¨': 'utf-8',
  'Ã´': 'utf-8',
  '�': 'ISO-8859-1'
}

const encodingsErrorsList = Object.keys(encodingsErrors)

export default function (text) {
  for (const err of encodingsErrorsList) {
    if (text.match(err)) { return encodingsErrors[err] }
  }
};
