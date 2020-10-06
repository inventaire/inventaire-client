import preq from 'lib/preq'
import behaviorsPlugin from 'modules/general/plugins/behaviors'
import requestItemModalTemplate from './templates/request_item_modal.hbs'

export default Marionette.ItemView.extend({
  template: requestItemModalTemplate,
  className: 'requestItemModal',
  behaviors: {
    PreventDefault: {},
    Loading: {},
    SuccessCheck: {},
    ElasticTextarea: {},
    General: {}
  },

  initialize () { return _.extend(this, behaviorsPlugin) },

  events: {
    'click a#sendItemRequest': 'sendRequest'
  },

  ui: {
    message: '#message'
  },

  onShow () {
    app.execute('modal:open')
  },

  serializeData () {
    return {
      item: this.model.serializeData(),
      user: this.userData(),
      suggestedText: this.suggestedText()
    }
  },

  userData () {
    // user should already have been fetched
    const user = app.users.findWhere({ username: this.model.username })
    return user.serializeData()
  },

  suggestedText () {
    const transaction = this.model.get('transaction')
    return `item_request_text_suggestion_${transaction}`
  },

  sendRequest () {
    this.startLoading('#sendItemRequest')
    return this.postRequest()
    .then(addTransaction)
    .then(showRequest)
    .catch(this.Fail('item request err'))
  },

  postRequest () {
    return preq.post(app.API.transactions, {
      action: 'request',
      item: this.model.id,
      message: this.ui.message.val()
    }).get('transaction')
  }
})

const addTransaction = transaction => app.request('transactions:add', transaction)

const showRequest = function (transaction) {
  app.execute('modal:close')
  app.execute('show:transaction', transaction.id)
}
