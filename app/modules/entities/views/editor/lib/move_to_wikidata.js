import log_ from 'lib/loggers'
import preq from 'lib/preq'

export default invEntityUri => {
  return preq.put(app.API.entities.moveToWikidata, { uri: invEntityUri })
  .then(log_.Info('RES'))
  // Get the refreshed, redirected entity
  // thus also updating entitiesModelsIndexedByUri
  .then(() => app.request('get:entity:model', invEntityUri, true))
}
