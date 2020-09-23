/* eslint-disable
    no-undef,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
export default function (params) {
  const { labels, claims, createOnWikidata } = params
  const prefix = createOnWikidata === true ? 'wd' : 'inv'
  return _.preq.post(app.API.entities.create, { prefix, labels, claims })
  .catch(_.ErrorRethrow(`create ${prefix} entity err`))
};
