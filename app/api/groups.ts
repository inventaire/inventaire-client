import { fixedEncodeURIComponent } from '#app/lib/utils'
import Commons from './commons.ts'
import { getEndpointPathBuilders } from './endpoint.ts'

const { base, action } = getEndpointPathBuilders('groups')

const {
  search,
  searchByPosition,
} = Commons

export default {
  base,
  byId (id) { return action('by-id', { id }) },
  bySlug (slug) { return action('by-slug', { slug }) },
  last: action('last'),
  search: search.bind(null, base),
  searchByPosition: searchByPosition.bind(null, base),
  slug (name, groupId) {
    name = fixedEncodeURIComponent(name)
    return action('slug', { name, group: groupId })
  },
}
