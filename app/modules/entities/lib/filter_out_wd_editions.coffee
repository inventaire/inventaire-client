# Filter-out Wikidata editions
# as their support is currently lacking:
# - works and editions are still quite mixed in Wikidaa
# - Wikidata editions might not have the claims expected of an edition
#   which might cause errors such as the impossibility to create an item
#   from this edition
module.exports = (entities)->
  entities.filter (entity)-> not entity.wikidataId
