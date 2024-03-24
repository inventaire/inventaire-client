import { compact, groupBy, pick, pluck, uniq } from 'underscore'
import { isNonEmptyArray } from '#lib/boolean_tests'
import { getUriNumericId } from '#lib/wikimedia/wikidata'
import { sortObjectKeys } from '#lib/utils'

// Formatter URLs can be found on Wikidata, see https://www.wikidata.org/wiki/Property:P1630
export const externalIdsDisplayConfigs = {
  'wdt:P213': {
    name: 'OCLC',
    category: 'bibliographicDatabases',
    getUrl: id => `https://isni.oclc.org/xslt/DB=1.2/CMD?ACT=SRCH&IKT=8006&TRM=ISN%3A${id}`,
  },
  'wdt:P214': {
    name: 'VIAF',
    category: 'bibliographicDatabases',
    getUrl: id => `https://viaf.org/viaf/${id}/`,
  },
  'wdt:P227': {
    name: 'DNB',
    category: 'bibliographicDatabases',
    getUrl: id => `https://d-nb.info/gnd/${id}`,
  },
  'wdt:P243': {
    name: 'WorldCat',
    category: 'bibliographicDatabases',
    getUrl: id => `https://www.worldcat.org/oclc/${id}`,
  },
  'wdt:P244': {
    name: 'Library of Congress',
    category: 'bibliographicDatabases',
    getUrl: id => `https://id.loc.gov/authorities/${id}`,
  },
  'wdt:P268': {
    name: 'BNF',
    category: 'bibliographicDatabases',
    getUrl: id => `https://catalogue.bnf.fr/ark:/12148/cb${id}`,
  },
  'wdt:P269': {
    name: 'IdRef',
    category: 'bibliographicDatabases',
    getUrl: id => `https://www.idref.fr/${id}`,
  },
  'wdt:P349': {
    name: 'NDL',
    category: 'bibliographicDatabases',
    getUrl: id => `https://id.ndl.go.jp/auth/ndlna/${id}`,
  },
  'wdt:P496': {
    name: 'ORCID',
    category: 'bibliographicDatabases',
    getUrl: id => `https://orcid.org/${id}`,
  },
  'wdt:P648': {
    name: 'OpenLibrary',
    category: 'bibliographicDatabases',
    getUrl: id => {
      const lastLetter = id.slice(-1)[0]
      const section = openLibrarySectionByLetter[lastLetter]
      return `https://openlibrary.org/${section}/${id}`
    },
  },
  'wdt:P675': {
    name: 'Google Books',
    category: 'bibliographicDatabases',
    getUrl: id => `https://books.google.com/books?id=${id}`,
  },
  'wdt:P906': {
    name: 'SELIBR',
    category: 'bibliographicDatabases',
    getUrl: id => `https://libris.kb.se/auth/${id}`,
  },
  'wdt:P950': {
    name: 'BNE',
    category: 'bibliographicDatabases',
    getUrl: id => `https://datos.bne.es/resource/${id}`,
  },
  'wdt:P1006': {
    name: 'Nationale Thesaurus voor Auteursnamen',
    category: 'bibliographicDatabases',
    getUrl: id => `https://data.bibliotheken.nl/doc/thes/p${id}`,
  },
  'wdt:P1025': {
    name: 'SUDOC',
    category: 'bibliographicDatabases',
    getUrl: id => `https://www.sudoc.fr/${id}`,
  },
  'wdt:P1044': {
    name: 'SWB',
    category: 'bibliographicDatabases',
    getUrl: id => `https://swb.bsz-bw.de/DB=2.1/PPNSET?PPN=${id}&INDEXSET=1`,
  },
  'wdt:P1085': {
    name: 'LibraryThing',
    category: 'bibliographicDatabases',
    getUrl: id => `https://www.librarything.com/work/${id}`,
  },
  'wdt:P1143': {
    name: 'BN',
    category: 'bibliographicDatabases',
    getUrl: id => `https://catalogo.bn.gov.ar/F/?func=direct&doc_number=${id}&local_base=GENER`,
  },
  'wdt:P1144': {
    name: 'Library of Congress',
    category: 'bibliographicDatabases',
    getUrl: id => `https://www.loc.gov/item/${id}/`,
  },
  'wdt:P1182': {
    name: 'LIBRIS',
    category: 'bibliographicDatabases',
    getUrl: id => `http://libris.kb.se/bib/${id}`,
  },
  'wdt:P1274': {
    name: 'ISFDB',
    category: 'bibliographicDatabases',
    getUrl: id => `https://www.isfdb.org/cgi-bin/title.cgi?${id}`,
  },
  'wdt:P1292': {
    name: 'DNB',
    category: 'bibliographicDatabases',
    getUrl: id => `https://d-nb.info/${id}`,
  },
  'wdt:P1844': {
    name: 'HathiTrust',
    category: 'bibliographicDatabases',
    getUrl: id => `https://catalog.hathitrust.org/Record/${id}`,
  },
  'wdt:P1960': {
    name: 'Google Scholar',
    category: 'bibliographicDatabases',
    getUrl: id => `https://scholar.google.com/citations?user=${id}`,
  },
  'wdt:P1982': {
    name: 'AnimeNewsNetwork',
    category: 'bibliographicDatabases',
    getUrl: id => `https://www.animenewsnetwork.com/encyclopedia/people.php?id=${id}`,
  },
  'wdt:P1983': {
    name: 'AnimeNewsNetwork',
    category: 'bibliographicDatabases',
    getUrl: id => `https://www.animenewsnetwork.com/encyclopedia/company.php?id=${id}`,
  },
  'wdt:P1984': {
    name: 'AnimeNewsNetwork',
    category: 'bibliographicDatabases',
    getUrl: id => `https://www.animenewsnetwork.com/encyclopedia/manga.php?id=${id}`,
  },
  'wdt:P2002': {
    name: 'Twitter',
    category: 'socialNetworks',
    getUrl: id => `https://twitter.com/${id}`,
  },
  'wdt:P2003': {
    name: 'Instagram',
    category: 'socialNetworks',
    getUrl: id => `https://www.instagram.com/${id}/`,
  },
  'wdt:P2013': {
    name: 'Facebook',
    category: 'socialNetworks',
    getUrl: id => `https://www.facebook.com/${id}`,
  },
  'wdt:P2397': {
    name: 'YouTube',
    category: 'socialNetworks',
    getUrl: id => `https://www.youtube.com/channel/${id}`,
  },
  'wdt:P2607': {
    name: 'BookBrainz',
    category: 'bibliographicDatabases',
    getUrl: id => `https://bookbrainz.org/author/${id}`,
  },
  'wdt:P2963': {
    name: 'Goodreads',
    category: 'bibliographicDatabases',
    getUrl: id => `https://www.goodreads.com/author/show/${id}`,
  },
  'wdt:P2969': {
    name: 'Goodreads',
    category: 'bibliographicDatabases',
    getUrl: id => `https://www.goodreads.com/book/show/${id}`,
  },
  'wdt:P3184': {
    name: 'Czech National Bibliography',
    category: 'bibliographicDatabases',
    getUrl: id => `https://aleph.nkp.cz/F/?func=find-b&find_code=CNB&local_base=cnb&request=${id}`,
  },
  'wdt:P3630': {
    name: 'Babelio',
    category: 'bibliographicDatabases',
    getUrl: id => `https://www.babelio.com/auteur/wd/${id}`,
  },
  'wdt:P3631': {
    name: 'Babelio',
    category: 'bibliographicDatabases',
    getUrl: id => `https://www.babelio.com/livres/wd/${id}`,
  },
  'wdt:P4033': {
    name: 'Mastodon',
    category: 'socialNetworks',
    getUrl: id => {
      const [ username, host ] = id.split('@')
      return `https://${host}/@${username}`
    },
  },
  'wdt:P4084': {
    name: 'MyAnimeList',
    category: 'bibliographicDatabases',
    getUrl: id => `https://myanimelist.net/people/${id}`,
  },
  'wdt:P4087': {
    name: 'MyAnimeList',
    category: 'bibliographicDatabases',
    getUrl: id => `https://myanimelist.net/manga/${id}`,
  },
  'wdt:P4285': {
    name: 'Theses.fr',
    category: 'bibliographicDatabases',
    getUrl: id => `https://www.theses.fr/${id}`,
  },
  'wdt:P5199': {
    name: 'British Library',
    category: 'bibliographicDatabases',
    getUrl: id => `http://explore.bl.uk/BLVU1:LSCOP-ALL:BLL01${id}`,
  },
  'wdt:P5331': {
    name: 'OCLC',
    category: 'bibliographicDatabases',
    getUrl: id => `http://classify.oclc.org/classify2/ClassifyDemo?owi=${id}`,
  },
  'wdt:P5361': {
    name: 'BNB',
    category: 'bibliographicDatabases',
    getUrl: id => `https://bnb.data.bl.uk/doc/person/${id}`,
  },
  'wdt:P5491': {
    name: "BD Gest'",
    category: 'bibliographicDatabases',
    getUrl: id => `https://www.bedetheque.com/auteur-${id}-BD-.html`,
  },
  'wdt:P5571': {
    name: 'NooSFere',
    category: 'bibliographicDatabases',
    getUrl: id => `https://www.noosfere.org/livres/EditionsLivre.asp?numitem=${id}`,
  },
  'wdt:P6947': {
    name: 'Goodreads',
    category: 'bibliographicDatabases',
    getUrl: id => `https://www.goodreads.com/series/${id}`,
  },
  'wdt:P7400': {
    name: 'LibraryThing',
    category: 'bibliographicDatabases',
    getUrl: id => `https://www.librarything.com/author/${id}`,
  },
  'wdt:P7823': {
    name: 'BookBrainz',
    category: 'bibliographicDatabases',
    getUrl: id => `https://bookbrainz.org/work/${id}`,
  },
  'wdt:P8063': {
    name: 'BookBrainz',
    category: 'bibliographicDatabases',
    getUrl: id => `https://bookbrainz.org/publisher/${id}`,
  },
  'wdt:P8383': {
    name: 'Goodreads',
    category: 'bibliographicDatabases',
    getUrl: id => `https://www.goodreads.com/work/editions/${id}`,
  },
  'wdt:P8513': {
    name: 'LibraryThing',
    category: 'bibliographicDatabases',
    getUrl: id => `https://www.librarything.com/nseries/${id}`,
  },
  'wdt:P8619': {
    name: "BD Gest'",
    category: 'bibliographicDatabases',
    getUrl: id => `https://www.bedetheque.com/serie-${id}-BD-.html`,
  },
  'wdt:P12048': {
    name: 'BookBrainz',
    category: 'bibliographicDatabases',
    getUrl: id => `https://bookbrainz.org/series/${id}`,
  },
  'wdt:P12319': {
    name: 'Babelio',
    category: 'bibliographicDatabases',
    getUrl: id => `https://www.babelio.com/serie/-/${id}`,
  },
  'wdt:P12351': {
    name: 'BookBrainz',
    category: 'bibliographicDatabases',
    getUrl: id => `https://bookbrainz.org/edition/${id}`,
  },
}

const openLibrarySectionByLetter = {
  A: 'authors',
  W: 'works',
  M: 'books',
}

export const websitesByName = {}
export const websitesByCategoryAndName = {}

for (const [ property, { name, category } ] of Object.entries(externalIdsDisplayConfigs)) {
  externalIdsDisplayConfigs[property].property = property
  websitesByCategoryAndName[category] = websitesByCategoryAndName[category] || {}
  websitesByCategoryAndName[category][name] = websitesByCategoryAndName[name] || []
  websitesByCategoryAndName[category][name].push(property)
  websitesByName[name] = websitesByName[name] || []
  websitesByName[name].push({ property, name, category })
}

const sortAlphabetically = (a, b) => a > b ? 1 : -1

for (const category of Object.keys(websitesByCategoryAndName)) {
  websitesByCategoryAndName[category] = sortObjectKeys(websitesByCategoryAndName[category], sortAlphabetically)
}

export const getDisplayedPropertiesByCategory = () => {
  const customProperties = app.user.get('customProperties')
  if (isNonEmptyArray(customProperties)) {
    const displayedProperties = pick(externalIdsDisplayConfigs, customProperties)
    return groupBy(Object.values(displayedProperties), 'category')
  } else {
    return {}
  }
}

export const categoryLabels = {
  bibliographicDatabases: 'bibliographic databases',
  socialNetworks: 'social networks',
}

export function getWebsitesNamesFromProperties (properties) {
  return uniq(compact(properties.map(getPropertyWebsiteName)))
}

function getPropertyWebsiteName (property) {
  return externalIdsDisplayConfigs[property]?.name
}

export function getPropertiesFromWebsitesNames (websitesNames) {
  return websitesNames.flatMap(getWebsiteProperties).sort(sortPropertiesByNumericId)
}

function getWebsiteProperties (websiteName) {
  return pluck(websitesByName[websiteName], 'property')
}

const sortPropertiesByNumericId = (a, b) => getUriNumericId(a) - getUriNumericId(b)
