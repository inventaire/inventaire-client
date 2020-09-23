require 'should'
_ = require './utils_builder'
__ = require '../root'
# As window is defined in utils_builder, this defines window.ISBN
require 'isbn2'

OnDetected = __.require 'modules', 'inventory/lib/scanner/on_detected'
fakeResult = (isbn)-> { codeResult: { code: isbn } }
validIsbn = '9782290482223'
validIsbn2 = '9781857028959'
interScanDelay = 200 + 10

describe 'isbn scanner detection', ->
  it 'should not add an isbn on the first scan', (done)->
    addedIsbns = []
    addIsbn = (result)-> addedIsbns.push result
    onDetected = OnDetected { addIsbn }
    onDetected fakeResult(validIsbn)
    addedIsbns.should.deepEqual []
    done()

  it 'should add an isbn after 2 successive scans', (done)->
    addedIsbns = []
    addIsbn = (result)-> addedIsbns.push result
    onDetected = OnDetected { addIsbn }
    onDetected fakeResult(validIsbn)
    Promise.resolve()
    .delay interScanDelay
    .then ->
      onDetected fakeResult(validIsbn)
      addedIsbns.should.deepEqual [ validIsbn ]
      done()

    .catch done

    return

  it 'should not add an isbn if preceded by a different valid isbn', (done)->
    addedIsbns = []
    addIsbn = (result)-> addedIsbns.push result
    onDetected = OnDetected { addIsbn }
    onDetected fakeResult(validIsbn)
    Promise.resolve()
    .delay interScanDelay
    .then ->
      onDetected fakeResult(validIsbn2)
      addedIsbns.should.deepEqual []
      done()

    .catch done

    return

  it 'should add an isbn after 2 successive scans, even if another valid isbn was scanned before', (done)->
    addedIsbns = []
    addIsbn = (result)-> addedIsbns.push result
    onDetected = OnDetected { addIsbn }
    onDetected fakeResult(validIsbn)
    Promise.resolve()
    .delay interScanDelay
    .then -> onDetected fakeResult(validIsbn2)
    .delay interScanDelay
    .then ->
      onDetected fakeResult(validIsbn)
      addedIsbns.should.deepEqual []
    .delay interScanDelay
    .then ->
      onDetected fakeResult(validIsbn)
      addedIsbns.should.deepEqual [ validIsbn ]
      done()

    .catch done

    return
