module.exports = class AuthorLi extends Backbone.Marionette.ItemView
  template: require 'views/entities/templates/author_li'
  tagName: "li"
  className: "wikidataEntity row"
  serializeData: ->
    lang = app.user.lang
    model = @model.toJSON()
    _.log model, 'model'

    attrs =
     pictures: model.flat?.pictures
     P31: model.flat?.claims.P31
     id: model.title

    if model.labels?[lang]?.value?
      attrs.label = model.labels[lang].value
    else if model.labels?.en?.value?
      attrs.label = model.labels.en.value
    else attrs.label = 'no label'

    _.log attrs, 'attrs'
    return attrs