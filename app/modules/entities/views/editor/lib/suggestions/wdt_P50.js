export default function (entity, index, propertyValuesCount) {
  const serieUri = entity.get('claims.wdt:P179.0')
  if (serieUri == null) { return }

  return app.request('get:entity:model', serieUri)
  .then(serie => serie.getExtendedAuthorsUris())
};
