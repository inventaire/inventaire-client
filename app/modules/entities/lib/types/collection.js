export default function() {
  _.extend(this, specificMethods);
  this.childrenClaimProperty = 'wdt:P195';
  this.subentitiesName = 'editions';
  this.setClaimsBasedAttributes();
  return this.on('change:claims', this.onClaimsChange.bind(this));
};

var specificMethods = {
  setLabelFromTitle() {
    // Take the label from the monolingual title property
    const title = this.get('claims.wdt:P1476.0');
    // inv collections will always have a title, but not the wikidata ones
    if (title != null) { return this.set('label', title); }
  },

  setClaimsBasedAttributes() {
    return this.setLabelFromTitle();
  },

  onClaimsChange(property, oldValue, newValue){
    return this.setClaimsBasedAttributes();
  },

  getChildrenCandidatesUris() {
    const publishersUris = this.get('claims.wdt:P123');
    if (publishersUris == null) { return Promise.resolve([]); }

    return app.request('get:entities:models', { uris: publishersUris })
    .then(models => Promise.all(_.invoke(models, 'initPublisherPublications'))
    .then(() => _.flatten(_.pluck(models, 'isolatedEditionsUris'))));
  }
};
