module.exports = (expectedState, expectedMainUser)->
  filter = (transac, index, collection)->
    rightState(transac, expectedState) and rightUser(transac, expectedMainUser)

rightState = (transaction, expectedState)->
  transaction.get('state') is expectedState

rightUser = (transaction, expectedMainUser)->
  if expectedMainUser is 'owner' then return transaction.mainUserIsOwner
  else return not transaction.mainUserIsOwner

