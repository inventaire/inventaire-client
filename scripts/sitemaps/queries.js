import wdk from 'wikibase-sdk/wikidata.org'

const { sparqlQuery } = wdk

const worksQueryBody = `VALUES (?work_type) { (wd:Q571) (wd:Q47461344) (wd:Q2831984) (wd:Q1004) (wd:Q1760610) (wd:Q8261) (wd:Q25379) (wd:Q386724) (wd:Q49084) (wd:Q8274) (wd:Q17518461) } .
?work wdt:P31 ?work_type .
FILTER NOT EXISTS { ?work wdt:P31 wd:Q3331189 . }`

// Not using ?series wdt:P31/wdt:P279* wd:Q47461344 .
// has the request tends to return timeouts
const worksQuery = `SELECT ?work WHERE { ${worksQueryBody} }`

const seriesQuery = `SELECT ?series WHERE {
# instance of book series or its subclasses (includes comic book series)
?series wdt:P31/wdt:P279* wd:Q277759 .
}`

const workPropertyQuery = function (P) {
  const base = `${worksQueryBody}
  ?work wdt:${P} ?item .`
  return sparqlQuery(`SELECT ?item WHERE { ${base} }`)
}

const editionPropertyQuery = P => {
  return sparqlQuery(`SELECT ?item WHERE { ?edition wdt:${P} ?item }`)
}

export default {
  works: sparqlQuery(worksQuery),
  series: sparqlQuery(seriesQuery),
  authors: workPropertyQuery('P50'),
  genres: workPropertyQuery('P136'),
  movements: workPropertyQuery('P135'),
  publishers: editionPropertyQuery('P123'),
  subjects: workPropertyQuery('P921'),
}
