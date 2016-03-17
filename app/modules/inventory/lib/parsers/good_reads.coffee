module.exports = (line)->
  # nullifying allows to use 'or'
  line = substituteValidCommas line
  values = line.split(',')
    .map replaceCommaPlaceholder
    .map nullifyEmptyString

  return data =
    isbn: getIsbn values
    title: values[1]
    authors: values[2]
    notes: values[21]

getIsbn = (values)->
  isbn = values[6] or values[5]
  # isbns look like "=""9780061709715"""
  if isbn? then return isbn.replace /("|=)/g, ''

# some values have an internal comma (ex: "Tapscott, Don")
# that we replaced by the improbable characters chain §@§
# so that we can recover it after having split on commas
substituteValidCommas = (line)->
  return line.replace /,"([^"]+),([^"]+)",/g, ",$1§@§$2,"

replaceCommaPlaceholder = (line)->
  return line.replace /§@§/g, ','

commaPlaceholder = '§@§'

nullifyEmptyString = (str)-> if str is '' then null else str
