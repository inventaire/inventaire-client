dataQuery = _.buildPath.bind(_, '/api/data/public')

module.exports =
  wdq: (query, pid, qid, refresh)->
    dataQuery
      api: 'wdq'
      query:query
      pid:pid
      qid:qid
      refresh: refresh

  commonsThumb: (file, width)->
    dataQuery
      api: 'commons-thumb'
      file: file
      width: width

  wikipediaExtract: (lang, title)->
    dataQuery
      api: 'wp-extract'
      lang: lang
      title: title

  openLibraryCover: (openLibraryId, type='book')->
    dataQuery
      api: 'openlibrary-cover'
      id: openLibraryId
      type: type

  enWpImage: (enWpTitle)->
    dataQuery
      api: 'en-wikipedia-image'
      title: enWpTitle
