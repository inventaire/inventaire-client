/* eslint-disable
    implicit-arrow-linebreak,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
let num
const days = []
for (num = 1; num <= 180; num++) {
  if ((num <= 30) || ((num % 10) === 0)) {
    days.push({ num })
  }
}

export default selectedDay => // creates a clone of days
  days.map(el => {
    if (el.num === selectedDay) { el.selected = true }
    return el
  })
