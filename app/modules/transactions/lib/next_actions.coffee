{ findNextActions, isArchived } = sharedLib('transactions')(_)
infoPartials = require './info_partials'
actionsData = require './actions_data'

getNextActionsData = (transaction)->
  nextActions = proxyFindNextActions transaction
  data = actionsData()[nextActions]
  unless data? then return
  data = addTransactionInfo data, transaction
  grabOtherUsername transaction, data

proxyFindNextActions = (transaction)->
  findNextActions sharedLibAdapter(transaction)

sharedLibAdapter = (transaction)->
  name: transaction.get 'transaction'
  state: transaction.get 'state'
  mainUserIsOwner: transaction.mainUserIsOwner

addTransactionInfo = (data, transaction)->
  transactionMode = transaction.get 'transaction'
  data.map (action)->
    action[transactionMode] = true
    action.itemId = transaction.get 'item'
    infoData = infoPartials[transactionMode][action.text]
    if infoData? then _.extend action, infoData
    return action

grabOtherUsername = (transaction, actions)->
  username = transaction.otherUserSnapshot()?.username
  actions.map (action)-> _.extend {}, action, { username }

module.exports =
  getNextActionsData: getNextActionsData
  isArchived: (transaction)-> isArchived sharedLibAdapter(transaction)
