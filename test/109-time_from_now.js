import 'should';
import _ from './utils_builder';
import __ from '../root';
const timeFromNow = __.require('lib', 'time_from_now');

describe('time from now', function() {
  it('should be a function', function(done){
    timeFromNow.should.be.a.Function();
    return done();
  });

  it('should take a time and return a data object', function(done){
    const now = Date.now();
    const timeData = timeFromNow(now);
    timeData.should.be.an.Object();
    timeData.key.should.be.an.String();
    timeData.amount.should.be.a.Number();
    return done();
  });

  it('should return just now', function(done){
    const time = Date.now();
    const timeData = timeFromNow(time);
    timeData.key.should.equal('just now');
    return done();
  });

  it('should return x seconds ago', function(done){
    const time = Date.now() - (30 * 1000);
    const timeData = timeFromNow(time);
    timeData.key.should.equal('x_seconds_ago');
    timeData.amount.should.be.aboveOrEqual(30);
    return done();
  });

  it('should return x minutes ago', function(done){
    const time = Date.now() - (30 * 60 * 1000);
    const timeData = timeFromNow(time);
    timeData.key.should.equal('x_minutes_ago');
    timeData.amount.should.be.aboveOrEqual(30);
    return done();
  });

  it('should return x hours ago', function(done){
    const time = Date.now() - (5 * 60 * 60 * 1000);
    const timeData = timeFromNow(time);
    timeData.key.should.equal('x_hours_ago');
    timeData.amount.should.be.aboveOrEqual(5);
    return done();
  });

  it('should return x days ago', function(done){
    const time = Date.now() - (5 * 24 * 60 * 60 * 1000);
    const timeData = timeFromNow(time);
    timeData.key.should.equal('x_days_ago');
    timeData.amount.should.be.aboveOrEqual(5);
    return done();
  });

  it('should return x months ago', function(done){
    const time = Date.now() - (5 * 30 * 24 * 60 * 60 * 1000);
    const timeData = timeFromNow(time);
    timeData.key.should.equal('x_months_ago');
    timeData.amount.should.be.aboveOrEqual(5);
    return done();
  });

  it('should return x years ago', function(done){
    const time = Date.now() - (5 * 365 * 24 * 60 * 60 * 1000);
    const timeData = timeFromNow(time);
    timeData.key.should.equal('x_years_ago');
    timeData.amount.should.be.aboveOrEqual(5);
    return done();
  });

  return it('should pass to the higher time unit when above 90%', function(done){
    const time = Date.now() - (360 * 24 * 60 * 60 * 1000);
    const timeData = timeFromNow(time);
    timeData.key.should.equal('x_years_ago');
    timeData.amount.should.be.aboveOrEqual(1);
    return done();
  });
});
