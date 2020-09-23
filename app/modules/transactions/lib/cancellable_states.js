// after which action should the transaction be displayed as cancellable
const commonOneWay = [ 'accepted' ]
const commonLending = [ 'accepted', 'confirmed' ]
// the owner can't cancel after 'requested', as she can already just 'decline'
// with the exact same effects
const requester = [ 'requested' ]

const oneWay = {
  requester: requester.concat(commonOneWay),
  owner: commonOneWay
}

const lending = {
  requester: requester.concat(commonLending),
  owner: commonLending
}

export { oneWay as giving, lending, oneWay as selling }
