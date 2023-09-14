import { i18n } from '#user/lib/i18n'
import { groupBy } from 'underscore'
import { isNonEmptyArray } from '#lib/boolean_tests'

const alphabetically = (a, b) => a.label > b.label ? 1 : -1

export const linkClaimsProperties = [
  { property: 'wdt:P268', label: 'BNF', category: 'bibliographicDatabases' },
  { property: 'wdt:P648', label: 'OpenLibrary', category: 'bibliographicDatabases' },
  { property: 'wdt:P2002', label: 'Twitter', category: 'socialNetworks' },
  { property: 'wdt:P2013', label: 'Facebook', category: 'socialNetworks' },
  { property: 'wdt:P2003', label: 'Instagram', category: 'socialNetworks' },
  { property: 'wdt:P2397', label: 'YouTube', category: 'socialNetworks' },
  { property: 'wdt:P4033', label: 'Mastodon', category: 'socialNetworks' },
]

export const linksClaimsPropertiesByCategory = groupBy(linkClaimsProperties, 'category')

for (const category of Object.keys(linksClaimsPropertiesByCategory)) {
  linksClaimsPropertiesByCategory[category] = linksClaimsPropertiesByCategory[category].sort(alphabetically)
}

export const getDisplayedPropertiesByCategory = () => {
  const customProperties = app.user.get('customProperties')
  if (isNonEmptyArray(customProperties)) {
    const displayedProperties = linkClaimsProperties.filter(({ property }) => {
      return customProperties.includes(property)
    })
    return groupBy(displayedProperties, 'category')
  } else {
    return {}
  }
}

export const categoryLabels = {
  bibliographicDatabases: i18n('bibliographic databases'),
  socialNetworks: i18n('social networks'),
}

// Formatter URLs can be found on Wikidata, see https://www.wikidata.org/wiki/Property:P1630
export const externalIdsUrlFormatters = {
  'wdt:P213': id => `https://isni.oclc.org/xslt/DB=1.2/CMD?ACT=SRCH&IKT=8006&TRM=ISN%3A${id}`,
  'wdt:P214': id => `https://viaf.org/viaf/${id}/`,
  'wdt:P227': id => `https://d-nb.info/gnd/${id}`,
  'wdt:P243': id => `https://www.worldcat.org/oclc/${id}`,
  'wdt:P244': id => `https://id.loc.gov/authorities/${id}`,
  'wdt:P268': id => `https://catalogue.bnf.fr/ark:/12148/cb${id}`,
  'wdt:P269': id => `https://www.idref.fr/${id}`,
  'wdt:P349': id => `https://id.ndl.go.jp/auth/ndlna/${id}`,
  'wdt:P496': id => `https://orcid.org/${id}`,
  'wdt:P648': id => {
    const lastLetter = id.slice(-1)[0]
    const section = openLibrarySectionByLetter[lastLetter]
    return `https://openlibrary.org/${section}/${id}`
  },
  'wdt:P675': id => `https://books.google.com/books?id=${id}`,
  'wdt:P906': id => `https://libris.kb.se/auth/${id}`,
  'wdt:P950': id => `https://datos.bne.es/resource/${id}`,
  'wdt:P1006': id => `https://data.bibliotheken.nl/doc/thes/p${id}`,
  'wdt:P1025': id => `https://www.sudoc.fr/${id}`,
  'wdt:P1044': id => `https://swb.bsz-bw.de/DB=2.1/PPNSET?PPN=${id}&INDEXSET=1`,
  'wdt:P1085': id => `https://www.librarything.com/work/${id}`,
  'wdt:P1143': id => `https://catalogo.bn.gov.ar/F/?func=direct&doc_number=${id}&local_base=GENER`,
  'wdt:P1144': id => `https://www.loc.gov/item/${id}/`,
  'wdt:P1182': id => `http://libris.kb.se/bib/${id}`,
  'wdt:P1274': id => `https://www.isfdb.org/cgi-bin/title.cgi?${id}`,
  'wdt:P1292': id => `https://d-nb.info/${id}`,
  'wdt:P1844': id => `https://catalog.hathitrust.org/Record/${id}`,
  'wdt:P1960': id => `https://scholar.google.com/citations?user=${id}`,
  'wdt:P1982': id => `https://www.animenewsnetwork.com/encyclopedia/people.php?id=${id}`,
  'wdt:P1983': id => `https://www.animenewsnetwork.com/encyclopedia/company.php?id=${id}`,
  'wdt:P1984': id => `https://www.animenewsnetwork.com/encyclopedia/manga.php?id=${id}`,
  'wdt:P2002': id => `https://twitter.com/${id}`,
  'wdt:P2003': id => `https://www.instagram.com/${id}/`,
  'wdt:P2013': id => `https://www.facebook.com/${id}`,
  'wdt:P2397': id => `https://www.youtube.com/channel/${id}`,
  'wdt:P2607': id => `https://bookbrainz.org/author/${id}`,
  'wdt:P2963': id => `https://www.goodreads.com/author/show/${id}`,
  'wdt:P2969': id => `https://www.goodreads.com/book/show/${id}`,
  'wdt:P3035': id => `https://grp.isbn-international.org/search/piid_solr?keys=${id}`,
  'wdt:P3184': id => `https://aleph.nkp.cz/F/?func=find-b&find_code=CNB&local_base=cnb&request=${id}`,
  'wdt:P3630': id => `https://www.babelio.com/auteur/wd/${id}`,
  'wdt:P3631': id => `https://www.babelio.com/livres/wd/${id}`,
  'wdt:P4033': id => {
    const [ username, host ] = id.split('@')
    return `https://${host}/@${username}`
  },
  'wdt:P4084': id => `https://myanimelist.net/people/${id}`,
  'wdt:P4087': id => `https://myanimelist.net/manga/${id}`,
  'wdt:P4285': id => `https://www.theses.fr/${id}`,
  'wdt:P5199': id => `http://explore.bl.uk/BLVU1:LSCOP-ALL:BLL01${id}`,
  'wdt:P5331': id => `http://classify.oclc.org/classify2/ClassifyDemo?owi=${id}`,
  'wdt:P5361': id => `https://bnb.data.bl.uk/doc/person/${id}`,
  'wdt:P5491': id => `https://www.bedetheque.com/auteur-${id}-BD-.html`,
  'wdt:P5571': id => `https://www.noosfere.org/livres/EditionsLivre.asp?numitem=${id}`,
  'wdt:P7400': id => `https://www.librarything.com/author/${id}`,
  'wdt:P7823': id => `https://bookbrainz.org/work/${id}`,
  'wdt:P8063': id => `https://bookbrainz.org/publisher/${id}`,
  'wdt:P8383': id => `https://www.goodreads.com/work/editions/${id}`,
}

const openLibrarySectionByLetter = {
  A: 'authors',
  W: 'works',
  M: 'books',
}
