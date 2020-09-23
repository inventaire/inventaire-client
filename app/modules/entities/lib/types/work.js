const publicDomainThresholdYear = new Date().getFullYear() - 70;
const commonsSerieWork = require('./commons_serie_work');
const filterOutWdEditions = require('../filter_out_wd_editions');
const getEntityItemsByCategories = require('../get_entity_items_by_categories');

export default function() {
  // Main property by which sub-entities are linked to this one: edition of
  this.childrenClaimProperty = 'wdt:P629';
  // inverse property: edition(s)
  this.subEntitiesInverseProperty = 'wdt:P747';

  this.usesImagesFromSubEntities = true;

  this.subentitiesName = 'editions';
  // extend before fetching sub entities to have access
  // to the custom @beforeSubEntitiesAdd
  _.extend(this, specificMethods);

  setPublicationYear.call(this);
  return setEbooksData.call(this);
};

var setPublicationYear = function() {
  const publicationDate = this.get('claims.wdt:P577.0');
  if (publicationDate != null) {
    this.publicationYear = parseInt(publicationDate.split('-')[0]);
    return this.inPublicDomain = this.publicationYear < publicDomainThresholdYear;
  }
};

const setImage = function() {
  let images;
  const editionsImages = _.compact(this.editions.map(getEditionImageData))
    .sort(bestImage)
    .map(_.property('image'));

  const workImage = this.get('image');
  // If the work is in public domain, we can expect Wikidata image to be better
  // if there is one. In any other case, prefer images from editions
  // as illustration from Wikidata for copyrighted content can be quite random.
  // Wikipedia and OpenLibrary work images follow the same rule for simplicity
  if ((workImage != null) && this.inPublicDomain) {
    images = [ workImage ].concat(editionsImages);
  } else {
    images = editionsImages;
    this.set('image', (images[0] || workImage));
  }

  return this.set('images', images.slice(0, 3));
};

var getEditionImageData = function(model){
  const image = model.get('image');
  if (image?.url == null) { return; }
  return {
    image,
    lang: model.get('lang'),
    publicationDate: model.get('publicationTime'),
    isCompositeEdition: model.get('isCompositeEdition')
  };
};

var bestImage = function(a, b){
  const { lang:userLang } = app.user;
  if (a.isCompositeEdition !== b.isCompositeEdition) {
    if (a.isCompositeEdition) { return 1;
    } else { return -1; }
  } else if (a.lang === b.lang) { return latestPublication(a, b);
  } else if (a.lang === userLang) { return -1;
  } else if (b.lang === userLang) { return 1;
  } else { return latestPublication(a, b); }
};

var latestPublication = (a, b) => b.publicationTime - a.publicationTime;

var setEbooksData = function() {
  const hasInternetArchivePage = (this.get('claims.wdt:P724.0') != null);
  const hasGutenbergPage = (this.get('claims.wdt:P2034.0') != null);
  const hasWikisourcePage = (this.get('wikisource.url') != null);
  this.set('hasEbooks', (hasInternetArchivePage || hasGutenbergPage || hasWikisourcePage));
  return this.set('gutenbergProperty', 'wdt:P2034');
};

var specificMethods = _.extend({}, commonsSerieWork, {
  // wait for setImage to have run
  getImageAsync() { return this.fetchSubEntities().then(() => this.get('image')); },
  getItemsByCategories: getEntityItemsByCategories,
  beforeSubEntitiesAdd: filterOutWdEditions,
  afterSubEntitiesAdd: setImage
}
);
