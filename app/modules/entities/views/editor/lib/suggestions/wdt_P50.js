/* eslint-disable
    no-undef,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
export default function (entity, index, propertyValuesCount) {
  const serieUri = entity.get('claims.wdt:P179.0')
  if (serieUri == null) { return }

  return app.request('get:entity:model', serieUri)
  .then(serie => serie.getExtendedAuthorsUris())
};
