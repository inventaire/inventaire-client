const encodingsErrors = {
  // characters showing that this encoding should be used instead
  'Ã©': 'utf-8',
  'Ã¨': 'utf-8',
  'Ã´': 'utf-8',
  '�': 'ISO-8859-1',
}

const encodingsErrorsList = Object.keys(encodingsErrors)

export default function (text) {
  for (const err of encodingsErrorsList) {
    if (text.match(err)) return encodingsErrors[err]
  }
}
