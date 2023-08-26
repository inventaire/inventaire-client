import 'should'
import { getTimeFromNowData } from '#lib/time'

describe('time from now', () => {
  it('should be a function', done => {
    getTimeFromNowData.should.be.a.Function()
    done()
  })

  it('should take a time and return a data object', done => {
    const now = Date.now()
    const timeData = getTimeFromNowData(now)
    timeData.should.be.an.Object()
    timeData.key.should.be.an.String()
    timeData.amount.should.be.a.Number()
    done()
  })

  it('should return just now', done => {
    const time = Date.now()
    const timeData = getTimeFromNowData(time)
    timeData.key.should.equal('just now')
    done()
  })

  it('should return x seconds ago', done => {
    const time = Date.now() - (30 * 1000)
    const timeData = getTimeFromNowData(time)
    timeData.key.should.equal('x_seconds_ago')
    timeData.amount.should.be.aboveOrEqual(30)
    done()
  })

  it('should return x minutes ago', done => {
    const time = Date.now() - (30 * 60 * 1000)
    const timeData = getTimeFromNowData(time)
    timeData.key.should.equal('x_minutes_ago')
    timeData.amount.should.be.aboveOrEqual(30)
    done()
  })

  it('should return x hours ago', done => {
    const time = Date.now() - (5 * 60 * 60 * 1000)
    const timeData = getTimeFromNowData(time)
    timeData.key.should.equal('x_hours_ago')
    timeData.amount.should.be.aboveOrEqual(5)
    done()
  })

  it('should return x days ago', done => {
    const time = Date.now() - (5 * 24 * 60 * 60 * 1000)
    const timeData = getTimeFromNowData(time)
    timeData.key.should.equal('x_days_ago')
    timeData.amount.should.be.aboveOrEqual(5)
    done()
  })

  it('should return x months ago', done => {
    const time = Date.now() - (5 * 30 * 24 * 60 * 60 * 1000)
    const timeData = getTimeFromNowData(time)
    timeData.key.should.equal('x_months_ago')
    timeData.amount.should.be.aboveOrEqual(5)
    done()
  })

  it('should return x years ago', done => {
    const time = Date.now() - (5 * 365 * 24 * 60 * 60 * 1000)
    const timeData = getTimeFromNowData(time)
    timeData.key.should.equal('x_years_ago')
    timeData.amount.should.be.aboveOrEqual(5)
    done()
  })

  it('should pass to the higher time unit when above 90%', done => {
    const time = Date.now() - (360 * 24 * 60 * 60 * 1000)
    const timeData = getTimeFromNowData(time)
    timeData.key.should.equal('x_years_ago')
    timeData.amount.should.be.aboveOrEqual(1)
    done()
  })
})
