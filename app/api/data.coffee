module.exports =
  wdq: (query, pid, qid)->
    _.buildPath '/api/data/public',
      api: 'wdq'
      query:query
      pid:pid
      qid:qid

  commonsThumb: (file, width)->
    _.buildPath '/api/data/public',
      api: 'commons-thumb'
      file: file
      width: width
