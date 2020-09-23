// A tree-shaked version of wikidata-sdk to fit the client's exact needs
// https://github.com/maxlath/wikidata-sdk

import { buildPath } from 'lib/location';

export default {
  searchEntities(params){
    const { search, limit, offset } = params;

    if (search?.length <= 0) { throw new Error("search can't be empty"); }

    const { lang } = app.user;

    return buildPath('https://www.wikidata.org/w/api.php', {
      action: 'wbsearchentities',
      search,
      language: lang,
      uselang: lang,
      limit,
      continue: offset,
      format: 'json',
      origin: '*'
    }
    );
  },

  isWikidataItemId(id){ return /^Q[0-9]+$/.test(id); },
  isWikidataPropertyId(id){ return /^P[0-9]+$/.test(id); }
};
