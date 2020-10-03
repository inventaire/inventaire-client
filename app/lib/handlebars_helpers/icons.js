import { parseQuery } from 'lib/location'
import { SafeString } from 'handlebars'

function _icon (name, classes = '') {
  // overriding the second argument that could be {hash:,data:}
  if (!_.isString(classes)) { classes = '' }
  if (_.isString(name)) {
    if (imagesList.includes(name)) {
      const src = images[name]
      return new SafeString(`<img class='icon ${classes}' src='${src}'>`)
    } else {
      return new SafeString(_.icon(name, classes))
    }
  }
}

export { _icon as icon }

const images = {
  'wikidata-colored': '/public/images/wikidata.svg',
  wikisource: '/public/images/wikisource-64.png',
  'barcode-scanner': '/public/images/barcode-scanner-64.png',
  gutenberg: '/public/images/gutenberg.png'
}

const imagesList = Object.keys(images)

export function iconLink (name, url, classes) {
  let title
  let linkClasses = ''
  if ((classes != null) && _.isObject(classes.hash)) {
    let i18n, i18nCtx;
    ({ title, i18n, i18nCtx, classes, linkClasses } = classes.hash)
    if (title == null) { title = _.i18n(i18n, i18nCtx) }
  }

  const icon = this.icon.call(null, name, classes)
  return this.link(icon, url, linkClasses, title)
}

export function iconLinkText (name, url, text, classes) {
  let title
  let linkClasses = ''
  if (_.isObject(name.hash)) {
    let i18n, I18n, i18nArgs;
    ({ name, url, classes, linkClasses, text, i18n, I18n, i18nArgs, title } = name.hash)
    // Expect i18nArgs to be a string formatted as a querystring
    i18nArgs = parseQuery(i18nArgs)
    if (I18n != null) {
      text = _.I18n(I18n, i18nArgs)
    } else if (i18n != null) { text = _.i18n(i18n, i18nArgs) }

    if (title != null) { title = _.I18n(title) }
  }

  const icon = this.icon.call(null, name, classes)
  return this.link(`${icon}<span>${text}</span>`, url, linkClasses, title)
}
