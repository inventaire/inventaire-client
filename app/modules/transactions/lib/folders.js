module.exports =
  ongoing:
    id: 'ongoing'
    filter: (transac, index, collection)-> not transac.archived
    icon: 'exchange'
    text: 'ongoing'
  archived:
    id: 'archived'
    filter: (transac, index, collection)-> transac.archived
    icon: 'archive'
    text: 'archived'
