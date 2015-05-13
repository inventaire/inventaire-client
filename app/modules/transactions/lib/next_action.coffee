module.exports = (transaction, mainUserIsOwner)->
  nextActions = getNextActionsList transaction.get('transaction')
  state = transaction.get('state')
  role = if mainUserIsOwner then 'owner' else 'requester'
  nextAction = nextActions[state][role]
  return _.log actionsData[nextAction], 'next action'


getNextActionsList = (transaction)->
  if transaction is 'lending' then nextActionsWithReturn
  else basicNextActions

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
nextActionsWithReturn = _.extend basicNextActions,
  confirmed:
    owner: 'returned'
    requester: 'waiting:returned'
  returned:
    owner: null #auto-archived
    requester: 'archive'

actionsData =
  'accept/decline':
    [
      {classes: 'accept', text: 'accept'},
      {classes: 'decline', text: 'decline'}
    ]
  'confirm': [{classes: 'confirm', text: 'confirm'}]
  'returned': [{classes: 'returned', text: 'returned'}]
  'archive': [{classes: 'archive', text: 'archive'}]
  'waiting:accepted': [{classes: 'waiting', text: 'waiting_accepted'}]
  'waiting:confirmed': [{classes: 'waiting', text: 'waiting_confirmation'}]
  'waiting:returned': [{classes: 'waiting', text: 'waiting_return_confirmation'}]
