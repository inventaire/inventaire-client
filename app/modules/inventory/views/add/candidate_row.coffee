CandidateInfo = require './candidate_info'

module.exports = Marionette.ItemView.extend
  tagName: 'li'
  template: require './templates/candidate_row'
  className: ->
    base = 'candidate-row'
    if @model.get('isInvalid') then base += ' invalid'
    else if @model.get('needInfo')
      base += ' need-info'
    else
      base += ' can-be-selected'
      if @model.get('selected') then base += ' selected'
    return base

  onShow: ->
    @listenTo @model, 'change', @lazyRender

  onRender: ->
    @updateClassName()
    @trigger 'selection:changed'

  ui:
    checkbox: 'input'

  events:
    'change input': 'updateSelected'
    'click .addInfo': 'addInfo'
    'click .remove': 'remov'
    # General click event: use stopPropagation to avoid triggering it
    # from other click event handlers
    'click': 'select'

  updateSelected: (e)->
    { checked } = e.currentTarget
    @model.set 'selected', checked
    e.stopPropagation()

  select: (e)->
    # Do not interpret click on anchors such as .existing-instances links as a select
    if e.target.tagName is 'A' then return

    if @model.canBeSelected()
      currentSelectedMode = @model.get 'selected'
      # Let the model events listener update the checkbox
      @model.set 'selected', not currentSelectedMode
    else if @model.get('needInfo') then @addInfo()

  addInfo: (e)->
    showCandidateInfo @model.get('isbn')
    .then (data)=>
      { title, authors } = data
      @model.set { title, authors, selected: true }
    .catch (err)->
      if err.message is 'modal closed' then return
      else throw err

    e?.stopPropagation()

  # Avoid overriding Backbone.View::remove
  remov: (e)->
    @model.collection.remove @model
    e.stopPropagation()

showCandidateInfo = (isbn)->
  return new Promise (resolve, reject)->
    app.layout.modal.show new CandidateInfo { resolve, reject, isbn }
