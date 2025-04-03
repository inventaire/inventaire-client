import assert_ from '#app/lib/assert_types'
import barcodeScanner from '#assets/images/barcode-scanner-64.png'
import gutenberg from '#assets/images/gutenberg.png'
import wikidataColored from '#assets/images/wikidata.svg'
import wikisource from '#assets/images/wikisource-64.png'

const iconAliases = {
  giving: 'heart',
  lending: 'refresh',
  selling: 'money',
  inventorying: 'cube',
}

export function icon (name, classes = '') {
  assert_.string(name)
  name = iconAliases[name] || name
  if (iconPaths[name] != null) {
    const src = iconPaths[name]
    return `<img class="icon icon-${name} ${classes}" src="${src}">`
  } else {
    return `<i class="fa fa-${name} ${classes}"></i>`
  }
}

const iconPaths = {
  'barcode-scanner': barcodeScanner,
  gutenberg,
  'wikidata-colored': wikidataColored,
  wikisource,
}
