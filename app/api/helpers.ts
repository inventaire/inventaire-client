import { config } from '#app/config'
import { i18nContentHash } from '#assets/js/build_metadata'

export function getBuster () {
  if (config.env === 'production') return `?${i18nContentHash}`
  else return `?${Date.now()}`
}
