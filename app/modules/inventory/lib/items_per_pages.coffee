sideNavWidth = 250
itemWidth = 200 + 50 #margins
itemHeight = 350 #more or less

module.exports = (margin=5)->
  return howManyItemsToFillTheScreen() + margin

howManyItemsToFillTheScreen = ->
  itemPerLine = Math.floor((window.screen.width - sideNavWidth) / itemWidth)
  lines = Math.ceil(window.screen.height / itemHeight)
  total = itemPerLine * lines
  if total < 10 then total = 10
  return total
