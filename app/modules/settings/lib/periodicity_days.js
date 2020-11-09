let num
const days = []
for (num = 1; num <= 180; num++) {
  if ((num <= 30) || ((num % 10) === 0)) {
    days.push({ num })
  }
}

// creates a clone of days
export default selectedDay => {
  return days.map(el => {
    if (el.num === selectedDay) el.selected = true
    return el
  })
}
