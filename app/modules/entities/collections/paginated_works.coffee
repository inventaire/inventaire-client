PaginatedEntities = require './paginated_entities'

module.exports = PaginatedEntities.extend
  typesWhitelist: [ 'work', 'serie', 'article' ]
