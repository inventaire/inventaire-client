ShelfLi = Marionette.ItemView.extend
  tagName: 'li'
  template: require './templates/shelf_li'

  events:
    'click .editButton': 'showUpdateShelfEditor'
    'click a.cancelShelfEdition': 'hideShelfEditor'
    'click a#validateShelf': 'updateShelf'
    'click .deleteButton': 'deleteShelf'

  showUpdateShelfEditor: (e)->
    shelfId = @model.get('_id')
    $("##{shelfId}").hide()
    $("##{shelfId}Editor").show().find('textarea').focus()
    e?.stopPropagation()

  hideShelfEditor: (e)->
    shelfId = @model.get('_id')
    $("##{shelfId}Editor").hide()
    $("##{shelfId}").show()
    e?.stopPropagation()

  updateShelf: (e)->
    shelfId = @model.get('_id')
    @hideShelfEditor()
    name = $("##{shelfId}Name").val()
    description = $("##{shelfId}Desc").val()
    listing = 'private'
    _.preq.post app.API.shelves.update, { id:shelfId, name, description, listing }
    .catch _.Error('shelf update error')

  deleteShelf: (e)->
    id = @model.get('_id')
    _.preq.post app.API.shelves.delete, { ids:id }

module.exports = Marionette.CollectionView.extend
  tagName: 'ul'
  childView: ShelfLi
