const { base, action } = require('./endpoint')('users');
import { search, searchByPosition } from './commons';

export default {
  byIds(ids){ return action('by-ids', { ids: ids.join('|') }); },
  byUsername(username){ return action('by-usernames', { usernames: username }); },
  search: search.bind(null, base),
  searchByPosition: searchByPosition.bind(null, base)
};
