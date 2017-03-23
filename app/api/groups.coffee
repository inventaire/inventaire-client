{ base, action } = require('./endpoint')('groups')
{ search, searchByPosition } = require './commons'

module.exports =
  base: base
  byId: (id)-> action 'by-id', { id }
  bySlug: (slug)-> action 'by-slug', { slug }
  last: action 'last'
  search: search.bind null, base
  searchByPosition: searchByPosition.bind null, base
  slug: (name, groupId)-> action 'slug', { name, group: groupId }
