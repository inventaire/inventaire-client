/* eslint-disable
    import/no-duplicates,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import fs from 'fs'
const index = 'public/index.html'

export default function (params) {
  let { filename, marker, modifier, commented } = params
  let text = fs.readFileSync(`app/assets/${filename}`, 'utf-8')
  if (modifier != null) { text = modifier(text) }
  let html = fs.readFileSync(index, 'utf-8')
  // useful for markers directly inserted in the html
  // which would be displayed on screen if not wrapped in a html comment
  if (commented) { marker = `<!-- ${marker} -->` }
  html = html.replace(marker, text)
  return fs.writeFileSync(index, html)
};
