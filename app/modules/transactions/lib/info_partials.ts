const i18nKey = key => ({ i18nKey: key })

// mapping transaction mode and next actions to info partial files
// in the folder app/modules/transactions/views/templates/info
// or, for simple text, to a i18nKey
export const giving = {
  accept_request: { acceptRequestOneWay: true },
  // 'decline_request':
  confirm_reception: i18nKey('confirm_reception_one_way'),
  // 'waiting_accepted':
  waiting_confirmation: { waitingConfirmationOneWay: true },
}

export const lending = {
  accept_request: { acceptRequestLending: true },
  // 'decline_request':
  // 'confirm_reception':
  // 'confirm_returned':
  // 'waiting_accepted':
  waiting_confirmation: i18nKey('book_displayed_unavailable'),
}

export const selling = {
  accept_request: { acceptRequestOneWay: true },
  // 'decline_request':
  confirm_reception: i18nKey('confirm_reception_one_way'),
  // 'waiting_accepted':
  waiting_confirmation: { waitingConfirmationOneWay: true },
}

export const inventorying = {}
