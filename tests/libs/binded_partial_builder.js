import 'should'
import BindedPartialBuilder from '#lib/binded_partial_builder'

const obj = {
  a (x, y) { return x + y + this.z },
  z: 5,
}

describe('BindedPartialBuilder', () => {
  it('should be a function', () => {
    BindedPartialBuilder.should.be.a.Function()
  })

  it('should return a function', () => {
    const partialBuilder = BindedPartialBuilder(obj, 'a')
    partialBuilder.should.be.a.Function()
  })

  it('should return a function that return a function binded to a context and possibly arguments', () => {
    const partialBuilder = BindedPartialBuilder(obj, 'a')
    partialBuilder.should.be.a.Function()
    const partial1 = partialBuilder(1)
    partial1.should.be.a.Function()
    partial1(2).should.equal(8)
    const partial2And3 = partialBuilder(2, 3)
    partial2And3.should.be.a.Function()
    partial2And3().should.equal(10)
    partial2And3(123, 12512521).should.equal(10)
  })
})
