module.exports = Backbone.Collection.extend
  comparator: (model)->
    # Push the 'unknown' entity at the bottom of the list
    if model.get('uri') is 'unknown' then Infinity
    else - model.get('count')
