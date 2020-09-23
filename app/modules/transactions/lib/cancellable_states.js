# after which action should the transaction be displayed as cancellable
commonOneWay = ['accepted']
commonLending = ['accepted', 'confirmed']
# the owner can't cancel after 'requested', as she can already just 'decline'
# with the exact same effects
requester = ['requested']

oneWay =
  requester: requester.concat commonOneWay
  owner: commonOneWay

lending =
  requester: requester.concat commonLending
  owner: commonLending

module.exports =
  giving: oneWay
  lending: lending
  selling: oneWay
