import { API } from '#app/api/api'
import log_ from '#app/lib/loggers'
import preq from '#app/lib/preq'

export default function (params) {
  const { labels, claims, createOnWikidata } = params
  const prefix = createOnWikidata === true ? 'wd' : 'inv'
  return preq.post(API.entities.create, { prefix, labels, claims })
  .catch(log_.ErrorRethrow(`create ${prefix} entity err`))
}
