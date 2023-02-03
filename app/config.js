import preq from '#lib/preq'

let waitForConfig

// Request configuration to the server and make it accessible at app.config
export async function getConfig () {
  waitForConfig = waitForConfig || preq.get(app.API.config)
  const config = await waitForConfig
  return config
}
