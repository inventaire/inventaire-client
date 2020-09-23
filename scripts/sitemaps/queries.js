import { sparqlQuery } from 'wikidata-sdk';

const worksQueryBody = `\
VALUES (?work_type) { (wd:Q571) (wd:Q47461344) (wd:Q2831984) (wd:Q1004) (wd:Q1760610) (wd:Q8261) (wd:Q25379) (wd:Q386724) (wd:Q49084) (wd:Q8274) (wd:Q17518461) } .
?work wdt:P31 ?work_type .
FILTER NOT EXISTS { ?work wdt:P31 wd:Q3331189 . }\
`;

// Not using ?series wdt:P31/wdt:P279* wd:Q47461344 .
// has the request tends to return timeouts
const worksQuery = `SELECT ?work WHERE { ${worksQueryBody} }`;

const seriesQuery = `SELECT ?series WHERE {
# instance of book series or its subclasses (includes comic book series)
?series wdt:P31/wdt:P279* wd:Q277759 .
}\
`;

const queryFromProperty = function(P, Q){
  const base = `\
${worksQueryBody}
?work wdt:${P} ?item .\
`;
  return sparqlQuery(`SELECT ?item WHERE { ${base} }`);
};

export default {
  works: sparqlQuery(worksQuery),
  series: sparqlQuery(seriesQuery),
  authors: queryFromProperty('P50'),
  genres: queryFromProperty('P136'),
  movements: queryFromProperty('P135'),
  subjects: queryFromProperty('P921')
};
