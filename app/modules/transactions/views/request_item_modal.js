import preq from '#lib/preq'
import behaviorsPlugin from '#general/plugins/behaviors'
import requestItemModalTemplate from './templates/request_item_modal.hbs'
import { isOpenedOutside } from '#lib/utils'
import '../scss/request_item_modal.scss'
import ElasticTextarea from '#behaviors/elastic_textarea'
import General from '#behaviors/general'
import Loading from '#behaviors/loading'
import PreventDefault from '#behaviors/prevent_default'
import SuccessCheck from '#behaviors/success_check'

export default Marionette.View.extend({
  template: requestItemModalTemplate,
  className: 'requestItemModal',
  behaviors: {
    ElasticTextarea,
    General,
    Loading,
    PreventDefault,
    SuccessCheck,
  },

  initialize () {
    _.extend(this, behaviorsPlugin)
  },

  events: {
    'click a#sendItemRequest': 'sendRequest',
    'click .item': 'showItem',
    'click .owner': 'showOwner',
  },

  ui: {
    message: '#message'
  },

  onRender () {
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
    this.postRequest()
    .then(addTransaction)
    .then(showRequest)
    .catch(this.Fail('item request err'))
  },

  showItem (e) {
    if (isOpenedOutside(e)) return

    // Case when the item was successfully grabbed by the transaction model
    if (this.model.item != null) {
      app.execute('show:item', this.model.item)
    } else {
      app.execute('show:item:byId', this.model.get('item'))
    }
  },

  showOwner (e) {
    if (!isOpenedOutside(e)) {
      app.execute('show:inventory:user', this.model.owner)
    }
  },

  async postRequest () {
    const { transaction } = await preq.post(app.API.transactions, {
      action: 'request',
      item: this.model.id,
      message: this.ui.message.val()
    })
    return transaction
  }
})

const addTransaction = transaction => app.request('transactions:add', transaction)

const showRequest = function (transaction) {
  app.execute('modal:close')
  app.execute('show:transaction', transaction.id)
}
