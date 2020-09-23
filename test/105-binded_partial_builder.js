/* eslint-disable
    camelcase,
    import/no-duplicates,
    no-unused-vars,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import should from 'should'
import __ from '../root'

const BindedPartialBuilder = __.require('lib', 'binded_partial_builder')

const obj = {
  a (x, y) { return x + y + this.z },
  z: 5
}

describe('BindedPartialBuilder', () => {
  it('should be a function', done => {
    BindedPartialBuilder.should.be.a.Function()
    return done()
  })

  it('should return a function', done => {
    const partialBuilder = BindedPartialBuilder(obj, 'a')
    partialBuilder.should.be.a.Function()
    return done()
  })

  return it('should return a function that return a function binded to a context and possibly arguments', done => {
    const partialBuilder = BindedPartialBuilder(obj, 'a')
    partialBuilder.should.be.a.Function()
    const partial1 = partialBuilder(1)
    partial1.should.be.a.Function()
    partial1(2).should.equal(8)
    const partial2_3 = partialBuilder(2, 3)
    partial2_3.should.be.a.Function()
    partial2_3().should.equal(10)
    partial2_3(123, 12512521).should.equal(10)
    return done()
  })
})
