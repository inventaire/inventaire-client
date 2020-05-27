
module.exports = Marionette.LayoutView.extend
  template: require './templates/contributive_entity_builder'
  serializeData: ->
    console.log("##### 5 ##",@options.resolvedEntry)
    @options
