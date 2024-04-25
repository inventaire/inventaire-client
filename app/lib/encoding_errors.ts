const encodingsErrors = {
  // characters showing that this encoding should be used instead
  'Ã©': 'utf-8',
  'Ã¨': 'utf-8',
  'Ã´': 'utf-8',
  // Using this hack to avoid getting the file falsly identified as a binary file (TS1490)
  [decodeURIComponent('%EF%BF%BD')]: 'ISO-8859-1',
}

const encodingsErrorsList = Object.keys(encodingsErrors)

export function testEncodingErrors (text: string) {
  for (const err of encodingsErrorsList) {
    if (text.match(err)) return encodingsErrors[err]
  }
}
