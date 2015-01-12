module.exports =
  src:
    root: "./public/i18n/src"
    fullkey: (path)-> "#{@root}/fullkey/#{path}.json"
    shortkey: (path)-> "#{@root}/shortkey/#{path}.json"
    wikidata: (path)-> "#{@root}/wikidata/#{path}.json"
  dist: (path)-> "./public/i18n/dist/#{path}.json"