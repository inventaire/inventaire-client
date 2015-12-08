days = []
for num in [1..180]
  if num <= 30 or num % 10 is 0
    days.push { num: num }

module.exports = (selectedDay)->
  daysClone = days.clone()
  # days[0].num === 1, thus the need to remove 1
  daysClone[selectedDay-1].selected = true
  return daysClone
