sideNavWidth = 250
itemWitdth = 200 + 50 #margins
# initializing private variables
start = null
end = null
itemsBatchLength = null
before = null
after = null

module.exports = ->
  itemsBatchLength = howManyItemsForTwoLines()
  app.commands.setHandlers
    'items:pagination:head': head
    'items:pagination:prev': prev
    'items:pagination:next': next
    'items:pagination:more': more

  app.reqres.setHandlers
    'items:pagination:before': -> before
    'items:pagination:after': -> after

head = ->
  updateRange
    start: 0
    end: itemsBatchLength
    label: 'head'

prev = ->
  updateRange
    start: start - itemsBatchLength
    end: start
    label: 'prev'

next = ->
  updateRange
    start: end
    end: end + itemsBatchLength
    label: 'next'

more = ->
  updateRange
    start: start
    end: end + itemsBatchLength
    label: 'more'

updateRange = (params)->
  {start, end, label} = params
  [before, after] = app.request 'filter:range', start, end
  app.vent.trigger 'items:list:before:after', before, after


howManyItemsForTwoLines = ->
  itemPerLine = (window.screen.width - sideNavWidth) / itemWitdth
  return Math.floor(itemPerLine) * 2
