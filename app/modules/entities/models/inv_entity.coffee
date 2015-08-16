Entity = require './entity'

module.exports = Entity.extend
  prefix: 'inv'
  initialize: ->
    # _.log @, 'init inv entity'
    @initLazySave()

    @id = @get('_id')

    canonical = pathname = "/entity/#{@prefix}:#{@id}"

    if title = @get('title')
      pathname += "/" + _.softEncodeURI(title)

    @set
      canonical: canonical
      pathname: pathname
      uri: "#{@prefix}:#{@id}"
      domain: 'inv'
