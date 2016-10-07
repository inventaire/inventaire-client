module.exports = Marionette.ItemView.extend
  tagName: 'tr'
  template: require './templates/candidate_row'
  ui:
    checkbox: 'input'

  events:
    'change input': 'updateSelected'

  modelEvents:
    'change:selected': 'updateCheckbox'

  updateCheckbox: (model, value)->
    # prevent updating the view if the change was due to the view change itself
    if @updatedFromView then @updatedFromView = false
    else @ui.checkbox.prop 'checked', value

  updateSelected: (e)->
    { checked } = e.currentTarget
    @updatedFromView = true
    @model.set 'selected', checked
    @trigger 'checkbox:change'
