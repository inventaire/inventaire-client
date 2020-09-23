/* eslint-disable
    implicit-arrow-linebreak,
    no-undef,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
export default invEntityUri => _.preq.put(app.API.entities.moveToWikidata, { uri: invEntityUri })
.then(_.Log('RES'))
.then(() => // Get the refreshed, redirected entity
// thus also updating entitiesModelsIndexedByUri
  app.request('get:entity:model', invEntityUri, true))
