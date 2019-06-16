module.exports = Marionette.LayoutView.extend
  # regions:
    # infoboxRegion
    # mergeSuggestionsRegion: '.mergeSuggestions'

  className: ->
    className = @baseClassName or ''
    if @options.standalone then className += ' standalone'
    return className.trim()

  Infobox: require './general_infobox'

  initialize: ->
    { @refresh, @standalone, @displayMergeSuggestions } = @options

  serializeData: ->
    displayMergeSuggestions: @displayMergeSuggestions

  onRender: ->
    @showInfobox()
    @showMergeSuggestions()

  showInfobox: ->
    { Infobox } = @
    @infoboxRegion.show new Infobox { @model, @standalone }

  showMergeSuggestions: ->
    unless @displayMergeSuggestions then return
    app.execute 'show:merge:suggestions', { @model, region: @mergeSuggestionsRegion }
