import should from 'should'
import loggers_ from '#lib/loggers'

describe('Logger', () => {
  describe('info', () => {
    it('should return a string for string input', done => {
      loggers_.info('salut').should.be.a.String()
      loggers_.info('ca va?', 'oui oui').should.be.a.String()
      done()
    })

    it('should return an object for object i nput', done => {
      loggers_.info({ ach: 'so' }).should.be.a.Object()
      loggers_.info({ ya: 'klar' }, 'doh').should.be.a.Object()
      done()
    })
  })

  describe('Info', () => {
    it('should return loggers_.info with a binded-label', done => {
      const waitingLog = loggers_.Info('hallo')
      waitingLog.should.be.a.Function()
      waitingLog({ hey: 'azegzagazere' })
      waitingLog({ hey: 'there' }).should.be.an.Object()
      done()
    })
  })

  describe('warn', () => it('should always return undefined', done => {
    should(loggers_.warn('yo')).not.be.ok()
    should(loggers_.warn('yo', { hello: 'wat' })).not.be.ok()
    should(loggers_.warn({ hello: 'wat' }, 'yo')).not.be.ok()
    done()
  }))

  describe('error', () => {
    it('should accept only error objects', done => {
      should(() => loggers_.error('yo')).throw()
      done()
    })

    it('should always return undefined', done => {
      should(loggers_.error(new Error('yo'))).not.be.ok()
      done()
    })
  })

  describe('Error', () => {
    it('should return an error logger that catches errors', done => {
      should(loggers_.Error('yo label')(new Error('yo'))).not.be.ok()

      Promise.reject(new Error('damned 1'))
      .catch(loggers_.Error('catching!'))
      .then(() => done())
    })
  })

  describe('ErrorRethrow', () => it('should return an error logger that rethrows errors', done => {
    Promise.reject(new Error('damned 2'))
    .catch(loggers_.ErrorRethrow('rethrowing!'))
    .catch(() => done())
    // should(loggers_.ErrorRethrow('yo label')('yo')).not.be.ok()
    // should(loggers_.ErrorRethrow('yo label')({hello: 'wat'})).not.be.ok()
  }))
})
