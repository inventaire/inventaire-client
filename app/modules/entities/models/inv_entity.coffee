Entity = require './entity'
getBestLangValue = require '../lib/get_best_lang_value'
wd_ = require 'lib/wikidata'

module.exports = Entity.extend
  prefix: 'inv'
  initialize: (attr)->
    { lang } = app.user
    label = getBestLangValue lang, null, attr.labels

    canonical = pathname = "/entity/#{@prefix}:#{@id}"

    if title = @get('title')
      pathname += '/' + _.softEncodeURI(title)

    @set
      title: label
      label: label
      canonical: canonical
      pathname: pathname
      uri: "#{@prefix}:#{@id}"
      domain: 'inv'
      wikidata:
        wiki: "#{pathname}/edit"

  getAuthorsString: ->
    unless @get('claims')? then return _.preq.resolve ''
    qids = @get('claims').P50
    return wd_.getLabel qids, app.user.lang
