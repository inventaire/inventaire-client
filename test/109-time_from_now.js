require 'should'
_ = require './utils_builder'
__ = require '../root'
timeFromNow = __.require 'lib', 'time_from_now'

describe 'time from now', ->
  it 'should be a function', (done)->
    timeFromNow.should.be.a.Function()
    done()

  it 'should take a time and return a data object', (done)->
    now = Date.now()
    timeData = timeFromNow now
    timeData.should.be.an.Object()
    timeData.key.should.be.an.String()
    timeData.amount.should.be.a.Number()
    done()

  it 'should return just now', (done)->
    time = Date.now()
    timeData = timeFromNow time
    timeData.key.should.equal 'just now'
    done()

  it 'should return x seconds ago', (done)->
    time = Date.now() - 30 * 1000
    timeData = timeFromNow time
    timeData.key.should.equal 'x_seconds_ago'
    timeData.amount.should.be.aboveOrEqual 30
    done()

  it 'should return x minutes ago', (done)->
    time = Date.now() - 30 * 60 * 1000
    timeData = timeFromNow time
    timeData.key.should.equal 'x_minutes_ago'
    timeData.amount.should.be.aboveOrEqual 30
    done()

  it 'should return x hours ago', (done)->
    time = Date.now() - 5 * 60 * 60 * 1000
    timeData = timeFromNow time
    timeData.key.should.equal 'x_hours_ago'
    timeData.amount.should.be.aboveOrEqual 5
    done()

  it 'should return x days ago', (done)->
    time = Date.now() - 5 * 24 * 60 * 60 * 1000
    timeData = timeFromNow time
    timeData.key.should.equal 'x_days_ago'
    timeData.amount.should.be.aboveOrEqual 5
    done()

  it 'should return x months ago', (done)->
    time = Date.now() - 5 * 30 * 24 * 60 * 60 * 1000
    timeData = timeFromNow time
    timeData.key.should.equal 'x_months_ago'
    timeData.amount.should.be.aboveOrEqual 5
    done()

  it 'should return x years ago', (done)->
    time = Date.now() - 5 * 365 * 24 * 60 * 60 * 1000
    timeData = timeFromNow time
    timeData.key.should.equal 'x_years_ago'
    timeData.amount.should.be.aboveOrEqual 5
    done()

  it 'should pass to the higher time unit when above 90%', (done)->
    time = Date.now() - 360 * 24 * 60 * 60 * 1000
    timeData = timeFromNow time
    timeData.key.should.equal 'x_years_ago'
    timeData.amount.should.be.aboveOrEqual 1
    done()
