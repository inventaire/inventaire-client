export default async function ({ entity }) {
  const serieUri = entity.claims['wdt:P179']?.[0]
  if (serieUri == null) return

  const serie = await app.request('get:entity:model', serieUri)
  return serie.getExtendedAuthorsUris()
}
