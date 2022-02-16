import log_ from '#lib/loggers'
import { capitalize } from '#lib/utils'
import { i18n } from '#modules/user/lib/i18n'
import { parseQuery } from '#lib/location'
import timeFromNow from '#lib/time_from_now'
import Handlebars from 'handlebars/runtime'
const { SafeString, escapeExpression } = Handlebars

export default {
  i18n (key, context) {
    // Allow to pass context through Handlebars hash object
    // ex: {{{i18n 'email_invitation_sent' email=this}}}
    // Use this mode for unsafe context values to get it escaped
    if (_.isObject(context?.hash)) context = escapeValues(context.hash)
    return i18n(key, context)
  },

  I18n (...args) { return capitalize(this.i18n.apply(this, args)) },

  I18nStartCase (...args) {
    return this.i18n.apply(this, args)
    .split(' ')
    .map(capitalize)
    .join(' ')
  },

  i18nLink (text, url, context, linkClasses) {
    text = i18n(text, context)
    return this.link(text, url, linkClasses)
  },

  I18nLink (text, url, context, linkClasses) {
    text = capitalize(i18n(text, context))
    return this.link(text, url, linkClasses)
  },

  // See also: iconLinkText
  link (text, url, classes, title) {
    // Polymorphism: accept arguments as hash key/value pairs
    // ex: {{link i18n='see_on_website' i18nArgs='website=wikidata.org' url=wikidata.url classes='link'}}
    let simpleOpenedAnchor
    if (_.isObject(text.hash)) {
      let i18nStr, i18nArgs, titleAttrKey, titleAttrValue;
      ({ text, i18n: i18nStr, i18nArgs, url, classes, title, titleAttrKey, titleAttrValue, simpleOpenedAnchor } = text.hash)

      if (titleAttrKey != null) {
        const titleArgs = {}
        titleArgs[titleAttrKey] = titleAttrValue
        title = i18n(title, titleArgs)
      }

      if (text == null) {
        // A flag to build a complex <a> tag but with more tags between the anchor tags
        if (simpleOpenedAnchor) {
          text = ''
        } else {
          // Expect i18nArgs to be a string formatted as a querystring
          i18nArgs = parseQuery(i18nArgs)
          text = i18n(i18nStr, i18nArgs)
        }
      }
    }

    const link = this.linkify(text, url, classes, title)

    if (simpleOpenedAnchor) {
      // Return only the first tag to let the possibility to add a complex innerHTML
      return new SafeString(link.replace('</a>', ''))
    } else {
      return new SafeString(link)
    }
  },

  capitalize (str) { return capitalize(str) },

  limit (text, limit) {
    if (text == null) return ''
    let t = text.slice(0, +limit + 1 || undefined)
    if (text.length > limit) t += '[...]'
    return new SafeString(t)
  },

  debug () {
    log_.info(arguments, 'hb debug arguments')
    return JSON.stringify(arguments[0])
  },

  localTimeString (time) {
    if (time != null) {
      return new Date(time).toLocaleString(app.user.lang)
    }
  },

  ISOTime (time) {
    if (time != null) {
      return new Date(time).toISOString()
    }
  },

  timeFromNow (time) {
    if (time == null) return
    const { key, amount } = timeFromNow(time)
    return i18n(key, { smart_count: amount })
  },

  stringify (obj) {
    if (_.isString(obj)) return obj
    else return JSON.stringify(obj, null, 2)
  }
}

const escapeValues = function (obj) {
  for (const key in obj) {
    const value = obj[key]
    obj[key] = escapeExpression(value)
  }
  return obj
}
