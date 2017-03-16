module.exports =
  partial: 'edition_creation'
  partialData: (workModel)->
    isbnInputData:
      nameBase: 'isbn'
      field:
        placeholder: _.i18n('ex:') + ' 2070368228'
        dotdotdot: ''
      button:
        icon: 'plus'
        text: 'add'
        classes: 'grey postfix sans-serif'
    addWithoutIsbnPath: addWithoutIsbnPath workModel

  clickEvents:
    isbnButton: require './create_edition_entity_from_work'
    withoutIsbn: (view, workModel, e)->
      app.execute 'show:entity:create', workEditionCreationData(workModel)

addWithoutIsbnPath = (workModel)->
  return _.buildPath '/entity/new', workEditionCreationData(workModel)

workEditionCreationData = (workModel)->
  type: 'edition',
  label: workModel.get 'label'
  claims: { 'wdt:P629': [ workModel.get('uri') ] }
