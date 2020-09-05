PaginatedEntities = require './paginated_entities'

module.exports = PaginatedEntities.extend
  typesAllowlist: [ 'work', 'serie', 'article' ]
