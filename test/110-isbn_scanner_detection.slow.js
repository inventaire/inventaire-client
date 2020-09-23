import 'should'
import _ from './utils_builder'
import __ from '../root'

// As window is defined in utils_builder, this defines window.ISBN
import 'isbn2'

const OnDetected = __.require('modules', 'inventory/lib/scanner/on_detected')
const fakeResult = isbn => ({
  codeResult: { code: isbn }
})
const validIsbn = '9782290482223'
const validIsbn2 = '9781857028959'
const interScanDelay = 200 + 10

describe('isbn scanner detection', () => {
  it('should not add an isbn on the first scan', done => {
    const addedIsbns = []
    const addIsbn = result => addedIsbns.push(result)
    const onDetected = OnDetected({ addIsbn })
    onDetected(fakeResult(validIsbn))
    addedIsbns.should.deepEqual([])
    return done()
  })

  it('should add an isbn after 2 successive scans', done => {
    const addedIsbns = []
    const addIsbn = result => addedIsbns.push(result)
    const onDetected = OnDetected({ addIsbn })
    onDetected(fakeResult(validIsbn))
    Promise.resolve()
    .delay(interScanDelay)
    .then(() => {
      onDetected(fakeResult(validIsbn))
      addedIsbns.should.deepEqual([ validIsbn ])
      return done()
    }).catch(done)
  })

  it('should not add an isbn if preceded by a different valid isbn', done => {
    const addedIsbns = []
    const addIsbn = result => addedIsbns.push(result)
    const onDetected = OnDetected({ addIsbn })
    onDetected(fakeResult(validIsbn))
    Promise.resolve()
    .delay(interScanDelay)
    .then(() => {
      onDetected(fakeResult(validIsbn2))
      addedIsbns.should.deepEqual([])
      return done()
    }).catch(done)
  })

  return it('should add an isbn after 2 successive scans, even if another valid isbn was scanned before', done => {
    const addedIsbns = []
    const addIsbn = result => addedIsbns.push(result)
    const onDetected = OnDetected({ addIsbn })
    onDetected(fakeResult(validIsbn))
    Promise.resolve()
    .delay(interScanDelay)
    .then(() => onDetected(fakeResult(validIsbn2)))
    .delay(interScanDelay)
    .then(() => {
      onDetected(fakeResult(validIsbn))
      return addedIsbns.should.deepEqual([])
    })
    .delay(interScanDelay)
    .then(() => {
      onDetected(fakeResult(validIsbn))
      addedIsbns.should.deepEqual([ validIsbn ])
      return done()
    }).catch(done)
  })
})
