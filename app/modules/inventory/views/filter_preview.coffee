GeneralInfobox = require 'modules/entities/views/general_infobox'

module.exports = Marionette.LayoutView.extend
  id: 'inner-filter-preview'
  template: require './templates/filter_preview'
  regions:
    author: '#authorPreview'
    genre: '#genrePreview'
    subject: '#subjectPreview'
    owner: '#ownerPreview'

  ui:
    authorPreviewHandler: '#authorPreviewHandler'
    genrePreviewHandler: '#genrePreviewHandler'
    subjectPreviewHandler: '#subjectPreviewHandler'
    ownerPreviewHandler: '#ownerPreviewHandler'

  initialize: ->
    @_activeRegions = {}

  events:
    'click .handler': 'highlightHandlerRegion'

  updatePreview: (name, model)->
    _.log arguments, 'updatePreview'
    if not model? or model.isUnknown then return @removePreview name

    region = @[name]

    unless region? then return

    @_activeRegions[name] = true

    region.show new GeneralInfobox { model, small: true }

    @highlightPreview name

  highlightPreview: (name)->
    @ui["#{name}PreviewHandler"].addClass 'shown'
    @$el.find('.preview-wrapper.active').removeClass 'active'
    # target .preview-wrapper
    @[name].$el.parent().addClass 'active'
    @$el.addClass 'shown'

  removePreview: (name)->
    @ui["#{name}PreviewHandler"].removeClass 'shown'
    # target .preview-wrapper
    @[name].$el.parent().removeClass 'active'
    delete @_activeRegions[name]
    fallbackRegion = Object.keys(@_activeRegions)[0]
    if fallbackRegion?
      @highlightPreview fallbackRegion
    else
      # target .preview-wrapper
      @$el.removeClass 'shown'

  highlightHandlerRegion: (e)->
    name = e.currentTarget.id.replace 'PreviewHandler', ''
    @highlightPreview name
