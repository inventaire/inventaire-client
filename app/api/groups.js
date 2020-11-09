import Commons from './commons'
import endpoint from './endpoint'
const { base, action } = endpoint('groups')

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
