export default {
  'wdt:P213': id => `https://isni.oclc.org/xslt/DB=1.2//CMD?ACT=SRCH&IKT=8006&TRM=ISN%3A${id}`,
  'wdt:P214': id => `https://viaf.org/viaf/${id}`,
  'wdt:P227': id => `https://d-nb.info/gnd/${id}`,
  'wdt:P244': id => `https://id.loc.gov/authorities/${id}`,
  'wdt:P268': id => `https://catalogue.bnf.fr/ark:/12148/cb${id}`,
  'wdt:P269': id => `https://www.idref.fr/${id}`,
  'wdt:P271': id => `https://ci.nii.ac.jp/author/${id}`,
  'wdt:P496': id => `https://orcid.org/${id}`,
  'wdt:P950': id => `http://datos.bne.es/persona/${id}.html`,
  'wdt:P1006': id => `https://data.bibliotheken.nl/id/thes/p${id}`,
  'wdt:P1015': id => `https://authority.bibsys.no/authority/rest/authorities/html/${id}`,
  'wdt:P7859': id => `https://www.worldcat.org/identities/${id}`
}
