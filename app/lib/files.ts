import log_ from '#lib/loggers'
import testEncodingErrors from './encoding_errors.ts'

const readFile = function (mode, file, encoding, verifyEncoding) {
  const reader = new FileReader()
  return new Promise((resolve, reject) => {
    reader.onerror = reject
    reader.onload = ParseReaderResult(mode, file, verifyEncoding, resolve)
    reader[mode](file, encoding)
  })
}

const ParseReaderResult = (mode, file, verifyEncoding, resolve) => readerEvent => {
  const { result } = readerEvent.target

  if (!verifyEncoding) {
    resolve(result)
    return
  }

  const differentEncoding = testEncodingErrors(result)
  if (differentEncoding) {
    log_.warn(differentEncoding, 'retrying file with different encoding')
    // retrying with different encoding but prevent
    // to enter a retry loop by passing verifyEncoding=false
    return resolve(readFile(mode, file, differentEncoding, false))
  } else {
    return resolve(result)
  }
}

// Parsing a 'change input[type=file]' event.
// mode: readAsDataURL or readAsText
// encoding: the expected encoding of the file. FileReader defaults to UTF-8.
const parseFileEvent = function (mode, e, expectOneFile = false, encoding) {
  const filesObjets = Array.from(e.target.files)
  // return a promise resolving to a file object
  if (expectOneFile) {
    return readFile(mode, filesObjets[0], encoding, true)
  // return a promise resolving to an array of files objects
  } else {
    const promises = filesObjets.map(file => readFile(mode, file, encoding, true))
    return Promise.all(promises)
  }
}

export function parseFileList ({ fileList, mode = 'readAsDataURL' }) {
  return Promise.all(Array.from(fileList).map(file => {
    return readFile(mode, file)
  }))
}

export async function getFirstFileDataUrl ({ fileList, mode = 'readAsDataURL' }) {
  const dataUrls = await parseFileList({ fileList, mode })
  return dataUrls[0]
}

export function resetFileInput (inputElement) {
  inputElement.value = ''
}

export default {
  parseFileEventAsDataURL: parseFileEvent.bind(null, 'readAsDataURL'),
  parseFileEventAsText: parseFileEvent.bind(null, 'readAsText'),
  readFile,
}
