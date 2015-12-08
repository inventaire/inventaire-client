days = []
for num in [1..180]
  if num <= 30 or num % 10 is 0
    days.push { num: num }

module.exports = (selectedDay)->
  # creates a clone of days
  return days.map (el)->
    if el.num is selectedDay then el.selected = true
    return el
