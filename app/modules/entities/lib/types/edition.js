import { unprefixify } from 'lib/wikimedia/wikidata';
import wdLang from 'wikidata-lang';
const farInTheFuture = '2100';
import getEntityItemsByCategories from '../get_entity_items_by_categories';
import error_ from 'lib/error';

export default function() {
  _.extend(this, specificMethods);
  this.setClaimsBasedAttributes();

  // Editions don't have subentities so the list of all their uris,
  // including their subentities, are limited to their own uri
  this.set('allUris', [ this.get('uri') ]);

  this.initWorksRelations();

};

var specificMethods = {
  setLang() {
    const langUri = this.get('claims.wdt:P407.0');
    const lang = langUri ? wdLang.byWdId[unprefixify(langUri)]?.code : undefined;
    return this.set('lang', lang);
  },

  setLabelFromTitle() {
    // Take the label from the monolingual title property
    return this.set('label', this.get('claims.wdt:P1476.0'));
  },

  setPublicationTime() {
    const publicationDate = this.get('claims.wdt:P577.0');
    const publicationTime = new Date(publicationDate || farInTheFuture).getTime();
    return this.set('publicationTime', publicationTime);
  },

  setClaimsBasedAttributes() {
    this.setLang();
    this.setLabelFromTitle();
    this.setPublicationTime();
    return this.set('isCompositeEdition', (this.get('claims.wdt:P629')?.length > 1));
  },

  onClaimsChange(property, oldValue, newValue){
    this.setClaimsBasedAttributes();
    if (property === 'wdt:P629') { return this.initWorksRelations(); }
  },

  getItemsByCategories: getEntityItemsByCategories,

  initWorksRelations() {
    // Works is pluralized to account for composite editions
    // cf https://github.com/inventaire/inventaire/issues/93
    const worksUris = this.get('claims.wdt:P629');

    if (worksUris == null) {
      if (this.creating) {
        this.works = [];
        startListeningForClaimsChanges.call(this);
        return this.waitForWorks = Promise.resolve();
      } else {
        const uri = this.get('uri');
        throw error_.new('edition entity misses associated works (wdt:P629)', { uri });
      }
    }

    return this.waitForWorks = this.reqGrab('get:entities:models', { uris: worksUris }, 'works')
    // Use tap to ignore the return values
    .tap(inheritData.bind(this))
    // Got to be initialized after inheritData is run to avoid running
    // several times at initialization
    .tap(startListeningForClaimsChanges.bind(this));
  },

  // Editions don't have subentities
  fetchSubEntities() { return Promise.resolve(); }
};

// Editions inherit some claims from their work but not all, as it could get confusing.
// Ex: publication date should not be inherited
var inheritData = function(works){
  // Do not set inherited claims when creating, as they would be sent as part of the claims
  // of the new entity, and rejected
  if (this.creating) { return; }
  // Use cases: used on the edition layout to display authors and series
  setWorksClaims.call(this, works, 'wdt:P50');
  setWorksClaims.call(this, works, 'wdt:P58');
  setWorksClaims.call(this, works, 'wdt:P110');
  setWorksClaims.call(this, works, 'wdt:P6338');
  setWorksClaims.call(this, works, 'wdt:P179');
};

var setWorksClaims = function(works, property){
  const values = _.chain(works)
    .map(work => work.get(`claims.${property}`))
    .flatten()
    .compact()
    .uniq()
    .value();
  if (values.length > 0) { return this.set(`claims.${property}`, values); }
};

var startListeningForClaimsChanges = function() {
  this.on('change:claims', this.onClaimsChange.bind(this));
  // Do no return the event listener return value as it was making Bluebird crash
  // (at least when passed to a .then)
};
