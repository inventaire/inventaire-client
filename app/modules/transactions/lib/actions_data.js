// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
const waiting = text => ({
  waiting: true,
  classes: 'waiting',
  text
})

export default () => ({
  'accept/decline':
    [
      { classes: 'accept', text: 'accept_request' },
      { classes: 'decline', text: 'decline_request' }
    ],

  confirm: [ { classes: 'confirm', text: 'confirm_reception' } ],
  returned: [ { classes: 'returned', text: 'confirm_returned' } ],
  'waiting:accepted': [ waiting('waiting_accepted') ],
  'waiting:confirmed': [ waiting('waiting_confirmation') ],
  'waiting:returned': [ waiting('waiting_return_confirmation') ]
})
