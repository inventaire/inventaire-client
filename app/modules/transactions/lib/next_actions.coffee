{ findNextActions, isArchived } = sharedLib('transactions')(_)

getNextActionsData = (transaction)->
  nextActions = proxyFindNextActions transaction
  data = actionsData[nextActions]
  if data?
    data = addTransactionInfo data, transaction
    grabOtherUsername transaction, data
  else return

proxyFindNextActions = (transaction)->
  findNextActions sharedLibAdapter(transaction)

sharedLibAdapter = (transaction)->
  name: transaction.get 'transaction'
  state: transaction.get 'state'
  mainUserIsOwner: transaction.mainUserIsOwner

addTransactionInfo = (data, transaction)->
  transactionMode = transaction.get('transaction')
  data.map (action)->
    action.info = "#{action.text}_info_#{transactionMode}"
    action.itemId = transaction.get('item')
    return action

grabOtherUsername = (transaction, actions)->
  username = transaction.otherUser()?.get('username')
  actions.map (action)-> _.extend {}, action, {username: username}

actionsData =
  'accept/decline':
    [
      {classes: 'accept', text: 'accept_request'},
      {classes: 'decline', text: 'decline_request'}
    ]
  'confirm': [{classes: 'confirm', text: 'confirm_reception'}]
  'returned': [{classes: 'returned', text: 'confirm_returned'}]
  'waiting:accepted': [{classes: 'waiting', text: 'waiting_accepted'}]
  'waiting:confirmed': [{classes: 'waiting', text: 'waiting_confirmation'}]
  'waiting:returned': [{classes: 'waiting', text: 'waiting_return_confirmation'}]


module.exports =
  getNextActionsData: getNextActionsData
  isArchived: (transaction)-> isArchived sharedLibAdapter(transaction)
