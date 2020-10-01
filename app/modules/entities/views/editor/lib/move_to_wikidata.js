import preq from 'lib/preq'

export default invEntityUri => {
  return preq.put(app.API.entities.moveToWikidata, { uri: invEntityUri })
  .then(_.Log('RES'))
  // Get the refreshed, redirected entity
  // thus also updating entitiesModelsIndexedByUri
  .then(() => app.request('get:entity:model', invEntityUri, true))
}
