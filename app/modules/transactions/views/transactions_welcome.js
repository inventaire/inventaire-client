import transactionsWelcomeTemplate from './templates/transactions_welcome.hbs'
import '../scss/transactions_welcome.scss'

export default Marionette.View.extend({
  className: 'transactionsWelcome',
  template: transactionsWelcomeTemplate
})
