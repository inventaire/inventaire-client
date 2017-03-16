wdLang = require 'wikidata-lang'

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
  data =
    type: 'edition',
    claims:
      'wdt:P629': [ workModel.get('uri') ]

  { lang } = app.user
  langWdId = wdLang.byCode[lang]?.wd
  langWdUri = if langWdId? then "wd:#{langWdId}"
  # Suggest the user's language as the edition language
  if langWdUri then data.claims['wdt:P407'] = [ langWdUri ]

  langWorkLabel = workModel.get "labels.#{lang}"
  # Suggest the work entity label in the user's language as the edition title
  if langWorkLabel then data.claims['wdt:P1476'] = [ langWorkLabel ]

  return data
