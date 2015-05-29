module.exports = (transaction)->
  nextActions = findNextActions(transaction)
  data = actionsData[nextActions]
  if data? then grabOtherUsername transaction, data
  else return

findNextActions = (transaction)->
  nextActions = getNextActionsList transaction.get('transaction')
  state = transaction.get('state')
  role = if transaction.mainUserIsOwner then 'owner' else 'requester'
  return nextActions[state][role]

getNextActionsList = (transaction)->
  if transaction is 'lending' then nextActionsWithReturn
  else basicNextActions

grabOtherUsername = (transaction, actions)->
  username = transaction.otherUser()?.get('username')
  actions.map (action)-> _.extend action, {username: username}

# key-1: current state
# key-2: main user role in this transaction
# value: possible actions
basicNextActions =
  requested:
    owner: 'accept/decline'
    requester: 'waiting:accepted'
  accepted:
    owner: 'waiting:confirmed'
    requester: 'confirm'
  declined:
    owner: null #auto-archived
    requester: 'archive'
  confirmed:
    owner: 'archive'
    requester: null #auto-archived

# customizing actions for transactions where the item should be returned
# currently only 'lending'
nextActionsWithReturn = _.extend {}, basicNextActions,
  confirmed:
    owner: 'returned'
    requester: 'waiting:returned'
  returned:
    owner: null #auto-archived
    requester: 'archive'

actionsData =
  'accept/decline':
    [
      {classes: 'accept', text: 'accept_request'},
      {classes: 'decline', text: 'decline_request'}
    ]
  'confirm': [{classes: 'confirm', text: 'confirm_reception'}]
  'returned': [{classes: 'returned', text: 'confirm_returned'}]
  'archive': [{classes: 'archive', text: 'archive'}]
  'waiting:accepted': [{classes: 'waiting', text: 'waiting_accepted'}]
  'waiting:confirmed': [{classes: 'waiting', text: 'waiting_confirmation'}]
  'waiting:returned': [{classes: 'waiting', text: 'waiting_return_confirmation'}]
