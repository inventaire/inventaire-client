import { identity } from 'underscore'
import { viewportIsSmall } from '#app/lib/screen'
import { i18n } from '#user/lib/i18n'

const gutenbergText = () => i18n('on_website', { name: 'Gutenberg.org' })

export const platforms = {
  'wdt:P724': {
    icon: 'archive-org',
    text () { return i18n('on_website', { name: 'Internet Archive' }) },
    url (id) { return `https://archive.org/details/${id}` },
  },
  'wdt:P1938': {
    icon: 'gutenberg',
    text: gutenbergText,
    url (id) { return `${gutenbergBase()}ebooks/author/${id}` },
  },
  'wdt:P2002': {
    icon: 'twitter',
    text (username) { return `@${username}` },
    url (username) { return `https://twitter.com/${username}` },
  },
  'wdt:P2003': {
    icon: 'instagram',
    text: identity,
    url (username) { return `https://instagram.com/${username}` },
  },
  'wdt:P2013': {
    icon: 'facebook',
    text: identity,
    url (facebookId) { return `https://facebook.com/${facebookId}` },
  },
  'wdt:P2034': {
    icon: 'gutenberg',
    text: gutenbergText,
    url (id) { return `${gutenbergBase()}ebooks/${id}` },
  },
  'wdt:P2397': {
    icon: 'youtube',
    text () { return '' },
    url (channelId) { return `https://www.youtube.com/channel/${channelId}` },
  },
  'wdt:P4033': {
    icon: 'mastodon',
    text: identity,
    url (address) {
      const [ username, domain ] = address.split('@')
      return `https://${domain}/@${username}`
    },
  },
  'wdt:P4258': {
    icon: 'gallica',
    text () { return i18n('on_website', { name: 'Gallica' }) },
    url (id) { return `https://gallica.bnf.fr/ark:/12148/${id}` },
  },
} as const

function gutenbergBase () {
  const base = viewportIsSmall() ? 'http://m.' : 'https://www.'
  return `${base}gutenberg.org/`
}
