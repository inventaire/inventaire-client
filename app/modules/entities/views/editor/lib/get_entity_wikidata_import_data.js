// Takes an Inventaire entity URI and a Wikidata entity URI,
// fetches the entities models, and return an object with the labels and claims
// set on the Inventaire entity but not on the Wikidata one to allow importing those

export default (invEntityUri, wdEntityUri) => app.request('get:entities:models', {
  uris: [ invEntityUri, wdEntityUri ],
  refresh: true,
  index: true
}).then(getImportData(invEntityUri, wdEntityUri));

var getImportData = (invEntityUri, wdEntityUri) => (function(models) {
  let claims;
  const invEntity = models[invEntityUri];
  const wdEntity = models[wdEntityUri];
  const importData = { labels: [], claims: [], invEntity, wdEntity };

  const object = invEntity.get('labels');
  for (let lang in object) {
    const label = object[lang];
    if (wdEntity.get(`labels.${lang}`) == null) {
      importData.labels.push({ lang, label });
    }
  }

  const object1 = invEntity.get('claims');
  for (let property in object1) {
    claims = object1[property];
    if (wdEntity.get(`claims.${property}`) == null) {
      // Import claims values one by one
      for (let value of claims) {
        if (_.isEntityUri(value)) {
          const prefix = value.split(':')[0];
          // Links to Inventaire entities can't be imported to Wikidata
          if (prefix === 'wd') { importData.claims.push({ property, value }); }
        } else {
          importData.claims.push({ property, value });
        }
      }
    }
  }

  importData.total = importData.labels.length + importData.claims.length;

  return importData;
});
