import Commons from './commons'
const { base, action } = require('./endpoint')('groups')

const {
  search,
  searchByPosition
} = Commons

export default {
  base,
  byId (id) { return action('by-id', { id }) },
  bySlug (slug) { return action('by-slug', { slug }) },
  last: action('last'),
  search: search.bind(null, base),
  searchByPosition: searchByPosition.bind(null, base),
  slug (name, groupId) { return action('slug', { name, group: groupId }) }
}
