import assert_ from '#lib/assert_types'
import { iconPaths } from '#lib/handlebars_helpers/icon_paths'

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
