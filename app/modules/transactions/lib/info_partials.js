import acceptRequestLending from 'modules/transactions/views/templates/info/accept_request_lending.hbs'
import acceptRequestOneWay from 'modules/transactions/views/templates/info/accept_request_one_way.hbs'
import waitingConfirmationOneWay from 'modules/transactions/views/templates/info/waiting_confirmation_one_way.hbs'

const i18nKey = key => ({ i18nKey: key })

// mapping transaction mode and next actions to info partial files
// in the folder app/modules/transactions/views/templates/info
// or, for simple text, to a i18nKey
export const giving = {
  accept_request: acceptRequestOneWay,
  // 'decline_request':
  confirm_reception: i18nKey('confirm_reception_one_way'),
  // 'waiting_accepted':
  waiting_confirmation: waitingConfirmationOneWay
}

export const lending = {
  accept_request: acceptRequestLending,
  // 'decline_request':
  // 'confirm_reception':
  // 'confirm_returned':
  // 'waiting_accepted':
  waiting_confirmation: i18nKey('book_displayed_unavailable')
}

export const selling = {
  accept_request: acceptRequestOneWay,
  // 'decline_request':
  confirm_reception: i18nKey('confirm_reception_one_way'),
  // 'waiting_accepted':
  waiting_confirmation: waitingConfirmationOneWay
}

export const inventorying = {}
