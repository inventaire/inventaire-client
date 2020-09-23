testEncodingErrors = require './encoding_errors'

readFile = (mode, file, encoding, verifyEncoding)->
  reader = new FileReader()
  new Promise (resolve, reject)->
    reader.onerror = reject
    reader.onload = ParseReaderResult mode, file, verifyEncoding, resolve
    reader[mode](file, encoding)

ParseReaderResult = (mode, file, verifyEncoding, resolve)->
  return parser = (readerEvent)->
    { result } = readerEvent.target

    unless verifyEncoding
      resolve result
      return

    differentEncoding = testEncodingErrors result
    if differentEncoding
      _.warn differentEncoding, 'retrying file with different encoding'
      # retrying with different encoding but prevent
      # to enter a retry loop by passing verifyEncoding=false
      resolve readFile(mode, file, differentEncoding, false)
    else
      resolve result

# Parsing a 'change input[type=file]' event.
# mode: readAsDataURL or readAsText
# encoding: the expected encoding of the file. FileReader defaults to UTF-8.
parseFileEvent = (mode, e, expectOneFile = false, encoding)->
  filesObjets = _.toArray e.target.files
  # return a promise resolving to a file object
  if expectOneFile
    return readFile mode, filesObjets[0], encoding, true
  # return a promise resolving to an array of files objects
  else
    promises = filesObjets.map (file)-> readFile mode, file, encoding, true
    return Promise.all promises

module.exports =
  parseFileEventAsDataURL: parseFileEvent.bind null, 'readAsDataURL'
  parseFileEventAsText: parseFileEvent.bind null, 'readAsText'
