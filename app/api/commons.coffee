module.exports =
  search: (base, text)->
    _.buildPath base,
      action: 'search'
      search: text

  searchByPosition: (base, latLng)->
    [lat, lng] = latLng
    return _.buildPath base,
      action: 'search-by-position'
      lat: lat
      lng: lng
