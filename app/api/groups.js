const { base, action } = require('./endpoint')('groups');
import { search, searchByPosition } from './commons';

export default {
  base,
  byId(id){ return action('by-id', { id }); },
  bySlug(slug){ return action('by-slug', { slug }); },
  last: action('last'),
  search: search.bind(null, base),
  searchByPosition: searchByPosition.bind(null, base),
  slug(name, groupId){ return action('slug', { name, group: groupId }); }
};
