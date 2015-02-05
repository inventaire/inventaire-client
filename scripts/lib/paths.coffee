module.exports =
  src:
    root: "./public/i18n/src"
    fk: (path)-> "#{@root}/fullkey/#{path}"
    sk: (path)-> "#{@root}/shortkey/#{path}"
    wd: (path)-> "#{@root}/wikidata/#{path}"
    fullkey: (name)-> @fk "#{name}.json"
    fullkeyArchive: (name)-> @fk "archive/#{name}.json"
    shortkey: (name)-> @sk "#{name}.json"
    shortkeyArchive: (name)-> @sk "archive/#{name}.json"
    wikidata: (name)-> @wd "#{name}.json"
    wikidataArchive: (name)-> @wd "archive/#{name}.json"
  distRoot: "./public/i18n/dist"
  dist: (name)-> "#{@distRoot}/#{name}.json"