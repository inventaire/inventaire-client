CandidateInfo = require './candidate_info'

module.exports = Marionette.ItemView.extend
  tagName: 'tr'
  template: require './templates/candidate_row'
  ui:
    checkbox: 'input'

  events:
    'change input': 'updateSelected'
    'click .addInfo': 'addInfo'

  modelEvents:
    'change:selected': 'updateCheckbox'

  updateCheckbox: (model, value)->
    if @model.get('isInvalid') then return
    # prevent updating the view if the change was due to the view change itself
    if @updatedFromView then @updatedFromView = false
    else @ui.checkbox.prop 'checked', value

  updateSelected: (e)->
    { checked } = e.currentTarget
    @updatedFromView = true
    @model.set 'selected', checked
    @trigger 'checkbox:change'

  addInfo: ->
    showCandidateInfo @model.get('isbn')
    .then (data)=>
      { title, authors } = data
      @model.set { title, authors, selected: true }
      @trigger 'checkbox:change'
      @render()
    .catch (err)->
      if err.message is 'modal closed' then return
      else throw err

showCandidateInfo = (isbn)->
  return new Promise (resolve, reject)->
    app.layout.modal.show new CandidateInfo { resolve, reject, isbn }
