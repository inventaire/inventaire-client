{ buildPath } = require 'lib/location'

module.exports =
  search: (base, text)->
    buildPath base,
      action: 'search'
      search: encodeURIComponent text

  searchByPosition: (base, bbox)->
    return buildPath base,
      action: 'search-by-position'
      # don't let buildPath do the bbox stringification
      # as it would uses a simple bbox.toString() and lose the []
      bbox: JSON.stringify bbox
