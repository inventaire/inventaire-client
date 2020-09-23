module.exports = (params)->
  { labels, claims, createOnWikidata } = params
  prefix = if createOnWikidata is true then 'wd' else 'inv'
  _.preq.post app.API.entities.create, { prefix, labels, claims }
  .catch _.ErrorRethrow("create #{prefix} entity err")
