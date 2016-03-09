readFile = (mode, file)->
  reader = new FileReader()
  new Promise (resolve, reject)->
    reader.onerror = reject
    reader.onload = (readerEvent) ->
      resolve readerEvent.target.result

    reader[mode](file)

readers =
  readAsDataURL: readFile.bind null, 'readAsDataURL'
  readAsText: readFile.bind null, 'readAsText'

# parsing a 'change input[type=file]' event
parseFileEvent = (mode, e)->
  filesObjets = _.toArray e.target.files
  return Promise.all filesObjets.map(readers[mode])

module.exports =
  parseFileEventAsDataURL: parseFileEvent.bind null, 'readAsDataURL'
  parseFileEventAsText: parseFileEvent.bind null, 'readAsText'
