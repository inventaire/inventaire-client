{ action } = require('./endpoint')('shelves')

module.exports =
  byId: (id)-> action 'by-ids', { ids: id, 'with-items': true }
  byIds: (ids)->
    ids = _.forceArray(ids).join '|'
    action 'by-ids', { ids, 'with-items': true }
  byOwners: (id)-> action 'by-owners', { 'owners': id }
  addItems: action 'add-items'
  deleteItems: action 'delete-items'
