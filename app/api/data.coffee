module.exports = (api, query, pid, qid)->
  _.buildPath '/api/data/public',
    api:api
    query:query
    pid:pid
    qid:qid