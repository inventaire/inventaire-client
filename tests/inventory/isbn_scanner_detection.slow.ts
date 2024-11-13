import 'should'
import { wait } from '#app/lib/promises'
import { onDetectedFactory } from '#inventory/lib/scanner/on_detected'

const fakeResult = isbn => ({
  codeResult: { code: isbn },
})
const validIsbn = '9782290482223'
const validIsbn2 = '9781857028959'
const interScanDelay = 200 + 10

const showInvalidIsbnWarning = (isbn: string) => isbn

describe('isbn scanner detection', () => {
  it('should not add an isbn on the first scan', async () => {
    const addedIsbns = []
    const addIsbn = (result: string) => addedIsbns.push(result)
    const onDetected = onDetectedFactory({ addIsbn, showInvalidIsbnWarning })
    onDetected(fakeResult(validIsbn))
    addedIsbns.should.deepEqual([])
  })

  it('should add an isbn after 2 successive scans', async () => {
    const addedIsbns = []
    const addIsbn = (result: string) => addedIsbns.push(result)
    const onDetected = onDetectedFactory({ addIsbn, showInvalidIsbnWarning })
    onDetected(fakeResult(validIsbn))
    await wait(interScanDelay)
    onDetected(fakeResult(validIsbn))
    addedIsbns.should.deepEqual([ validIsbn ])
  })

  it('should not add an isbn if preceded by a different valid isbn', async () => {
    const addedIsbns = []
    const addIsbn = (result: string) => addedIsbns.push(result)
    const onDetected = onDetectedFactory({ addIsbn, showInvalidIsbnWarning })
    onDetected(fakeResult(validIsbn))
    await wait(interScanDelay)
    onDetected(fakeResult(validIsbn2))
    addedIsbns.should.deepEqual([])
  })

  it('should add an isbn after 2 successive scans, even if another valid isbn was scanned before', async () => {
    const addedIsbns = []
    const addIsbn = (result: string) => addedIsbns.push(result)
    const onDetected = onDetectedFactory({ addIsbn, showInvalidIsbnWarning })
    onDetected(fakeResult(validIsbn))
    await wait(interScanDelay)
    onDetected(fakeResult(validIsbn2))
    await wait(interScanDelay)
    onDetected(fakeResult(validIsbn))
    await addedIsbns.should.deepEqual([])
    await wait(interScanDelay)
    onDetected(fakeResult(validIsbn))
    addedIsbns.should.deepEqual([ validIsbn ])
  })
})
