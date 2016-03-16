encodingsErrors =
  # characters showing that this encoding should be used instead
  'Ã©': 'utf-8'
  'Ã¨': 'utf-8'
  'Ã´': 'utf-8'
  '�': 'ISO-8859-1'

encodingsErrorsList = Object.keys encodingsErrors

module.exports = (text)->
  for err in encodingsErrorsList
    if text.match(err) then return encodingsErrors[err]
  return
