import log_ from 'lib/loggers'
import preq from 'lib/preq'

export default function (params) {
  const { labels, claims, createOnWikidata } = params
  const prefix = createOnWikidata === true ? 'wd' : 'inv'
  return preq.post(app.API.entities.create, { prefix, labels, claims })
  .catch(log_.ErrorRethrow(`create ${prefix} entity err`))
};
