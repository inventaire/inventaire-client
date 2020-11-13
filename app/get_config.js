import preq from 'lib/preq'

// Request configuration to the server and make it accessible at app.config
export default async function () {
  const config = await preq.get(app.API.config)
  app.config = config
  return config
}
