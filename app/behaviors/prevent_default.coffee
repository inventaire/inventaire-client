module.exports = class PreventDefault extends Marionette.Behavior
  events:
    'click a': 'triggerPreventDefault'

  triggerPreventDefault: (e)->
    defaulted = _.hasValue(e.target.className.split(' '), 'default')
    unless (defaulted or e.ctrlKey or e.shiftKey)
      e.preventDefault()
      _.log 'behaviors: preventDefault'
    else
      _.log [e,e.target,e.target.className], 'behaviors: not preventDefault'