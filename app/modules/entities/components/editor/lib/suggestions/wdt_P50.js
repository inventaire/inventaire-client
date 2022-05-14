import { difference } from 'underscore'

export default async function ({ entity }) {
  const serieUri = entity.claims['wdt:P179']?.[0]
  if (serieUri == null) return
  const serie = await app.request('get:entity:model', serieUri)
  const authorsUris = entity.claims['wdt:P50'] || []
  const serieAuthorsUris = await serie.getExtendedAuthorsUris()
  return difference(serieAuthorsUris, authorsUris)
}
