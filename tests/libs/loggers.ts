import should from 'should'
import loggers_ from '#app/lib/loggers'

describe('Logger', () => {
  describe('info', () => {
    it('should return a string for string input', () => {
      loggers_.info('salut').should.be.a.String()
      loggers_.info('ca va?', 'oui oui').should.be.a.String()
    })

    it('should return an object for object i nput', () => {
      loggers_.info({ ach: 'so' }).should.be.a.Object()
      loggers_.info({ ya: 'klar' }, 'doh').should.be.a.Object()
    })
  })

  describe('Info', () => {
    it('should return loggers_.info with a binded-label', () => {
      const waitingLog = loggers_.Info('hallo')
      waitingLog.should.be.a.Function()
      waitingLog({ hey: 'azegzagazere' })
      waitingLog({ hey: 'there' }).should.be.an.Object()
    })
  })

  describe('warn', () => it('should always return undefined', () => {
    should(loggers_.warn('yo')).not.be.ok()
    should(loggers_.warn('yo', { hello: 'wat' })).not.be.ok()
    should(loggers_.warn({ hello: 'wat' }, 'yo')).not.be.ok()
  }))

  describe('error', () => {
    it('should accept only error objects', () => {
      should(() => loggers_.error('yo')).throw()
    })

    it('should always return undefined', () => {
      should(loggers_.error(new Error('yo'))).not.be.ok()
    })
  })

  describe('Error', () => {
    it('should return an error logger that catches errors', async () => {
      should(loggers_.Error('yo label')(new Error('yo'))).not.be.ok()

      await Promise.reject(new Error('damned 1'))
      .catch(loggers_.Error('catching!'))
    })
  })

  describe('ErrorRethrow', () => {
    it('should return an error logger that rethrows errors', async () => {
      const message = 'verdammt'
      await Promise.reject(new Error(message))
      .catch(loggers_.ErrorRethrow('rethrowing!'))
      .catch(err => err.message.should.equal(message))
      // should(loggers_.ErrorRethrow('yo label')('yo')).not.be.ok()
      // should(loggers_.ErrorRethrow('yo label')({hello: 'wat'})).not.be.ok()
    })
  })
})
