import { fixedEncodeURIComponent } from '#app/lib/utils'
import type { AbsoluteUrl } from '#server/types/common'

// For more complete data (author, license, ...)
// See in the server repo: server/data/commons/thumb.js
export function thumbnail (file, width = 100) {
  if (file == null) return
  if (!alreadyEncoded(file)) file = fixedEncodeURIComponent(file)
  // Example:
  // - 2000px-Gallimard,_rue_Gallimard.jpg => Gallimard,_rue_Gallimard.jpg
  file = file.replace(/^\d+px-/, '')
  return `https://commons.wikimedia.org/wiki/Special:FilePath/${file}?width=${width}` as AbsoluteUrl
}

const alreadyEncoded = file => file.match(/%[0-9A-F]/) != null
