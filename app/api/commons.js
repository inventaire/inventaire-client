import { buildPath } from 'lib/location'
import { truncateDecimals } from 'modules/map/lib/geo.coffee'

export default {
  search (base, text) {
    return buildPath(base, {
      action: 'search',
      search: encodeURIComponent(text)
    }
    )
  },

  searchByPosition (base, bbox) {
    return buildPath(base, {
      action: 'search-by-position',
      // don't let buildPath do the bbox stringification
      // as it would uses a simple bbox.toString() and lose the []
      bbox: JSON.stringify(bbox.map(truncateDecimals))
    }
    )
  }
}
