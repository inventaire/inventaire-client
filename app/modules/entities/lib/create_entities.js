import Entity from '../models/entity';
import error_ from 'lib/error';
import isbn_ from 'lib/isbn';
import createEntity from './create_entity';
import { addModel as addEntityModel } from 'modules/entities/lib/entities_models_index';
import graphRelationsProperties from './graph_relations_properties';
import getOriginalLang from 'modules/entities/lib/get_original_lang';

const createWorkEdition = function(workEntity, isbn){
  _.types(arguments, ['object', 'string']);

  return isbn_.getIsbnData(isbn)
  .then(function(isbnData){
    let { title, groupLang:editionLang } = isbnData;
    _.log(title, 'title from isbn data');
    if (!title) { title = getTitleFromWork(workEntity, editionLang); }
    _.log(title, 'title after work suggestion');

    if (title == null) { throw error_.new('no title could be found', isbn); }

    const claims = {
      // instance of (P31) -> edition (Q3331189)
      'wdt:P31': [ 'wd:Q3331189' ],
      // isbn 13 (isbn 10 - if it exist - will be added by the server)
      'wdt:P212': [ isbnData.isbn13h ],
      // edition or translation of (P629) -> created book
      'wdt:P629': [ workEntity.get('uri') ],
      'wdt:P1476': [ title ]
    };

    if (isbnData.image != null) {
      claims['invp:P2'] = [ isbnData.image ];
    }

    return createAndGetEntity({ labels: {}, claims })
    .then(function(editionEntity){
      // If work editions have been fetched, add it to the list
      workEntity.editions?.add(editionEntity);
      workEntity.push('claims.wdt:P747', editionEntity.get('uri'));
      return editionEntity;
    });
  });
};

var getTitleFromWork = function(workEntity, editionLang){
  const inEditionLang = workEntity.get(`labels.${editionLang}`);
  if (inEditionLang != null) { return inEditionLang; }

  const inUserLang = workEntity.get(`labels.${app.user.lang}`);
  if (inUserLang != null) { return inUserLang; }

  const originalLang = getOriginalLang(workEntity.get('claims'));
  const inWorkOriginalLang = workEntity.get(`labels.${originalLang}`);
  if (inWorkOriginalLang != null) { return inWorkOriginalLang; }

  const inEnglish = workEntity.get('labels.en');
  if (inEnglish != null) { return inEnglish; }

  return workEntity.get('labels')[0];
};

const byProperty = function(options){
  let { property, name, relationEntity, createOnWikidata, lang } = options;
  if (!lang) { ({
    lang
  } = app.user); }

  const wdtP31 = subjectEntityP31ByProperty[property];
  if (wdtP31 == null) {
    throw error_.new('no entity creation function associated to this property', options);
  }

  const labels = { [lang]: name };
  const claims = { 'wdt:P31': [ wdtP31 ] };

  if (property === 'wdt:P179') {
    claims['wdt:P50'] = relationEntity.get('claims.wdt:P50');
  }

  return createAndGetEntity({ labels, claims, createOnWikidata });
};

var subjectEntityP31ByProperty = {
  // human
  'wdt:P50': 'wd:Q5',
  // publisher
  'wdt:P123': 'wd:Q2085381',
  // serie
  'wdt:P179': 'wd:Q277759',
  // work
  'wdt:P629': 'wd:Q47461344',
  'wdt:P655': 'wd:Q5',
  'wdt:P2679': 'wd:Q5',
  'wdt:P2680': 'wd:Q5'
};

var createAndGetEntity = function(params){
  const { claims } = params;
  return createEntity(params)
  .tap(triggerEntityGraphChangesEvents(claims))
  .then(entityData => new Entity(entityData))
  // Update the local cache
  .tap(addEntityModel);
};

var triggerEntityGraphChangesEvents = claims => (function() {
  for (let prop in claims) {
    const values = claims[prop];
    if (graphRelationsProperties.includes(prop)) {
      // Signal to the entity that it was affected by another entity's change
      // so that it refreshes it's graph data next time
      app.execute('invalidate:entities:graph', values);
    }
  }

});

export { createAndGetEntity as create, createWorkEdition as workEdition, byProperty };
