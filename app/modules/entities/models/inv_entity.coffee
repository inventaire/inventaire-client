Entity = require './entity'

module.exports = class InvEntity extends Entity
  prefix: 'inv'
  initialize: ->
    _.log @, 'init inv entity'
    @initLazySave()

    @id = @get('_id')

    pathname = "/entity/#{@prefix}:#{@id}"

    if title = @get('title')
      pathname += "/" + _.softEncodeURI(title)

    @set 'pathname', pathname
    @set 'uri', "#{@prefix}:#{@id}"
