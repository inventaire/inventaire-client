let num;
const days = [];
for (num = 1; num <= 180; num++) {
  if ((num <= 30) || ((num % 10) === 0)) {
    days.push({ num });
  }
}

export default selectedDay => // creates a clone of days
days.map(function(el){
  if (el.num === selectedDay) { el.selected = true; }
  return el;
});
