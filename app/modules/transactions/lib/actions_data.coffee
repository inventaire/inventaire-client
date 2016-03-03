module.exports = ->
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
