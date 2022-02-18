import { I18n, i18n } from '#modules/user/lib/i18n'
import { parseQuery } from '#lib/location'
import { icon as _icon } from '#lib/utils'
import wikidataColored from '#assets/images/wikidata.svg'
import wikisource from '#assets/images/wikisource-64.png'
import barcodeScanner from '#assets/images/barcode-scanner-64.png'
import gutenberg from '#assets/images/gutenberg.png'
import Handlebars from 'handlebars/runtime'
const { SafeString } = Handlebars

export function icon (name, classes = '') {
  // overriding the second argument that could be {hash:,data:}
  if (!_.isString(classes)) classes = ''
  if (_.isString(name)) {
    if (imagesList.includes(name)) {
      const src = images[name]
      return new SafeString(`<img class='icon ${classes}' src='${src}'>`)
    } else {
      return new SafeString(_icon(name, classes))
    }
  }
}

const images = {
  'wikidata-colored': wikidataColored,
  wikisource,
  'barcode-scanner': barcodeScanner,
  gutenberg,
}

const imagesList = Object.keys(images)

export function iconLink (name, url, classes) {
  let title
  let linkClasses = ''
  if ((classes != null) && _.isObject(classes.hash)) {
    let i18nStr, I18nStr, i18nArgs;
    ({ title, i18n: i18nStr, I18n: I18nStr, i18nArgs, classes, linkClasses } = classes.hash)
    if (title == null) {
      if (I18nStr != null) {
        title = I18n(I18nStr, i18nArgs)
      } else if (i18n != null) {
        title = i18n(i18nStr, i18nArgs)
      }
    }
  }

  const iconHtml = this.icon.call(null, name, classes)
  return this.link(iconHtml, url, linkClasses, title)
}

export function iconLinkText (name, url, text, classes) {
  let title
  let linkClasses = ''
  if (_.isObject(name.hash)) {
    let i18nStr, I18nStr, i18nArgs;
    ({ name, url, classes, linkClasses, text, i18n: i18nStr, I18n: I18nStr, i18nArgs, title } = name.hash)
    // Expect i18nArgs to be a string formatted as a querystring
    i18nArgs = parseQuery(i18nArgs)
    if (I18nStr != null) {
      text = I18n(I18nStr, i18nArgs)
    } else if (i18n != null) {
      text = i18n(i18nStr, i18nArgs)
    }

    if (title != null) title = I18n(title)
  }

  const icon = this.icon.call(null, name, classes)
  return this.link(`${icon}<span>${text}</span>`, url, linkClasses, title)
}
