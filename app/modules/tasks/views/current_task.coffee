AuthorLayout = require 'modules/entities/views/author_layout'

module.exports = Marionette.LayoutView.extend
  template: require './templates/current_task'
  serializeData: ->
    _.extend @model.toJSON(),
      suspect: @model.suspect?.toJSON()
      suggestion: @model.suggestion?.toJSON()
      goodLexicalScore: @model.get('lexicalScore') > 10

  regions:
    suspect: '#suspect'
    suggestion: '#suggestion'
    otherSuggestions: '#otherSuggestions'

  onShow: ->
    @showAuthor 'suspect'
    @showAuthor 'suggestion'

  showAuthor: (name)->
    @[name].show new AuthorLayout
      model: @model[name]
      initialWorksListLength: 20
      wrapWorks: true
      noAuthorWrap: true
