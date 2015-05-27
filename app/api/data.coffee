dataQuery = _.buildPath.bind(_, '/api/data/public')

module.exports =
  wdq: (query, pid, qid)->
    dataQuery
      api: 'wdq'
      query:query
      pid:pid
      qid:qid

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
