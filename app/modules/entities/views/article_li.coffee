module.exports = Marionette.ItemView.extend
  template: require './templates/article_li'
  className: 'articleLi'
  serializeData: ->
    attrs = @model.toJSON()
    attrs.editable.articleCustomStyle = true
    _.extend attrs,
      href: @getHref()
      hasDate: @hasDate()

  getHref: ->
    DOI = @model.get('claims.wdt:P356.0')
    if DOI? then "https://dx.doi.org/#{DOI}"

  hasDate: -> @model.get('claims.wdt:P577.0')?
