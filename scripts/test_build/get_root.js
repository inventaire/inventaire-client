/* eslint-disable
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
const [ target ] = Array.from(process.argv.slice(2))

export default function () {
  if (target === 'prod') {
    return 'https://inventaire.io'
  } else { return 'http://localhost:3006' }
};
