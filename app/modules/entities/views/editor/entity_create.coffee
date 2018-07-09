entityDraftModel = require '../../lib/entity_draft_model'

module.exports = Marionette.LayoutView.extend
  id: 'entityCreate'
  template: require './templates/entity_create'

  regions:
    typedEntityEdit: '#typedEntityEdit'

  ui:
    typePicker: '.typePicker'

  events:
    'click .typePicker a': 'updateTypePickerFromClick'

  onShow: ->
    @selectType 'work'

  selectType: (type)->
    @showTypedEntityEdit type
    @updateTypePicker type

  showTypedEntityEdit: (type)->
    { label, claims } = @options
    params = { type, label, claims }
    params.model = entityDraftModel.create params
    params.region = @typedEntityEdit
    app.execute 'show:entity:edit:from:params',  params

  updateTypePicker: (type)->
    @ui.typePicker.find('.selected').removeClass 'selected'
    @ui.typePicker.find("##{type}Picker").addClass 'selected'

  updateTypePickerFromClick: (e)->
    type = e.currentTarget.id.replace 'Picker', ''
    @selectType type
