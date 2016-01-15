module.exports = Marionette.ItemView.extend
  template: require './templates/article_li'
  tagName: 'li'
  className: 'articleLi'
  serializeData: ->
    attrs = @model.toJSON()
    attrs.wikidata.customStyle = true
    _.extend attrs,
      href: @getHref()
      hasDate: @hasDate()

  getHref: ->
    DOI = @model.get('claims')?.P356?[0]
    if DOI? then "https://dx.doi.org/#{DOI}"

  hasDate: -> @model.get('claims')?.P577?[0]?
