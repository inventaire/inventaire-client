module.exports =
  search: (base, text)->
    _.buildPath base,
      action: 'search'
      search: encodeURIComponent text

  searchByPosition: (base, bbox)->
    return _.buildPath base,
      action: 'search-by-position'
      # don't let buildPath do the bbox stringification
      # as it would uses a simple bbox.toString() and lose the []
      bbox: JSON.stringify bbox
