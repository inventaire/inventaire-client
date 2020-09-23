/* eslint-disable
    import/no-duplicates,
    no-undef,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import wdk from 'lib/wikidata-sdk'
import isbn_ from 'lib/isbn'

export default function (text) {
  text = text.trim()
  if (_.isEntityUri(text)) { return text }
  if (wdk.isWikidataItemId(text)) { return 'wd:' + text }
  if (_.isInvEntityId(text)) { return 'inv:' + text }
  if (isbn_.looksLikeAnIsbn(text)) { return 'isbn:' + isbn_.normalizeIsbn(text) }
};
