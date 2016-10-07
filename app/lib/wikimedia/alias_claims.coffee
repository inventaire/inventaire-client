aliases = sharedLib 'wikidata_aliases'

module.exports = (claims)->
  for id, claim of claims
    # if this Property could be assimilated to another Property
    # add this Property values to the main one
    aliasId = aliases[id]
    if aliasId?
      before = claims[aliasId] or= []
      aliased = claims[id]
      try
        # uniq can not test uniqueness on objects
        _.types before, 'strings...|numbers...'
        _.types aliased, 'strings...|numbers...'
        after = _.uniq before.concat(aliased)
        # _.log [aliasId, before, id, aliased, aliasId, after], 'entity aliasingClaims'
        claims[aliasId] = after
      catch err
        _.warn [err, id, claim], 'aliasingClaims err'
  return claims
