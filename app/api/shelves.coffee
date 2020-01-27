{ base, action } = require('./endpoint')('shelves')

module.exports =
  base: base
  byId: (id)-> action 'by-ids', { ids: id, 'with-items': true }
  byIds: (ids)->
    ids = _.forceArray(ids).join '|'
    action 'by-ids', { ids, 'with-items': true }
  byOwners: (id)-> action 'by-owners', { 'owners': id }
  addItems: action 'add-items'
  deleteItems: action 'delete-items'
  create: action 'create'
  update: action 'update'
  delete: action 'delete'
