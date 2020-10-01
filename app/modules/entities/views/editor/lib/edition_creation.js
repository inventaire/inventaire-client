import wdLang from 'wikidata-lang'
import { buildPath } from 'lib/location'

export default {
  partial: 'edition_creation',
  partialData (workModel) {
    return {
      isbnInputData: {
        nameBase: 'isbn',
        field: {
          placeholder: _.i18n('ex:') + ' 2070368228',
          dotdotdot: ''
        },
        button: {
          icon: 'plus',
          text: _.i18n('add'),
          classes: 'grey postfix sans-serif'
        }
      },
      addWithoutIsbnPath: addWithoutIsbnPath(workModel)
    }
  },

  clickEvents: {
    isbnButton: require('./create_edition_entity_from_work'),
    withoutIsbn (params) {
      const { work: workModel, itemToUpdate } = params
      app.execute('show:entity:create', workEditionCreationData(workModel, itemToUpdate))
      // In case the edition list was opened in a modal
      return app.execute('modal:close')
    }
  }
}

const addWithoutIsbnPath = function (workModel) {
  if (!workModel) { return {} }
  return buildPath('/entity/new', workEditionCreationData(workModel))
}

const workEditionCreationData = function (workModel, itemToUpdate) {
  const data = {
    type: 'edition',
    claims: {
      'wdt:P629': [ workModel.get('uri') ]
    }
  }

  data.itemToUpdate = itemToUpdate

  const { lang } = app.user
  const langWdId = wdLang.byCode[lang]?.wd
  const langWdUri = (langWdId != null) ? `wd:${langWdId}` : undefined
  // Suggest the user's language as the edition language
  if (langWdUri) { data.claims['wdt:P407'] = [ langWdUri ] }

  const langWorkLabel = workModel.get(`labels.${lang}`)
  // Suggest the work entity label in the user's language as the edition title
  if (langWorkLabel) { data.claims['wdt:P1476'] = [ langWorkLabel ] }

  return data
}
