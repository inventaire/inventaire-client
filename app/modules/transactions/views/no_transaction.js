import noTransactionTemplate from './templates/no_transaction.hbs'

export default Marionette.ItemView.extend({
  className: 'noTransaction',
  template: noTransactionTemplate
})
