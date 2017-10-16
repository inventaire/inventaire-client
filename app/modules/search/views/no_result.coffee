module.exports = Marionette.ItemView.extend
  className: 'no-result'
  template: require './templates/no_result'
  events:
    # Passing the result to the parent layout
    'click': -> @triggerMethod 'noresult:click'
