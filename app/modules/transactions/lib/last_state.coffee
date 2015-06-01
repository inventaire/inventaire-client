common = ['declined', 'cancelled']
oneWay = _.union ['confirmed'], common
twoWay = _.union ['returned'], common

module.exports =
  giving: oneWay
  lending: twoWay
  selling: oneWay
