export const externalIdsUrlFormatters = {
  'wdt:P268': id => `https://catalogue.bnf.fr/ark:/12148/cb${id}`,
  'wdt:P648': id => {
    const lastLetter = id.slice(-1)[0]
    const section = openLibrarySectionByLetter[lastLetter]
    return `https://openlibrary.org/${section}/${id}`
  },
  'wdt:P2002': id => `https://twitter.com/${id}`,
  'wdt:P2013': id => `https://www.facebook.com/${id}`,
  'wdt:P2003': id => `https://www.instagram.com/$${id}`,
  'wdt:P2397': id => `https://www.youtube.com/channel/${id}`,
  'wdt:P4033': id => {
    const [ username, host ] = id.split('@')
    return `https://${host}/@${username}`
  },
}

const openLibrarySectionByLetter = {
  A: 'authors',
  W: 'works',
  M: 'books',
}
