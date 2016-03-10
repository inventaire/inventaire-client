readFile = (mode, file, encoding)->
  reader = new FileReader()
  new Promise (resolve, reject)->
    reader.onerror = reject
    reader.onload = (readerEvent) ->
      resolve readerEvent.target.result

    reader[mode](file, encoding)

# Parsing a 'change input[type=file]' event.
# mode: readAsDataURL or readAsText
# encoding: the expected encoding of the file
# ex: ISO-8859-1
parseFileEvent = (mode, e, expectOneFile=false, encoding)->
  filesObjets = _.toArray e.target.files
  reader = readFile.bind null, mode

  # return a promise resolving to a file object
  if expectOneFile then return reader filesObjets[0], encoding
  # return a promise resolving to an array of files objects
  else return Promise.all filesObjets.map(reader)

module.exports =
  parseFileEventAsDataURL: parseFileEvent.bind null, 'readAsDataURL'
  parseFileEventAsText: parseFileEvent.bind null, 'readAsText'
