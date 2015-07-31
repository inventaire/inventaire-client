Entity = require './entity'

module.exports = Entity.extend
  prefix: 'inv'
  initialize: ->
    # _.log @, 'init inv entity'
    @initLazySave()

    @id = @get('_id')

    pathname = "/entity/#{@prefix}:#{@id}"

    if title = @get('title')
      pathname += "/" + _.softEncodeURI(title)

    @set
      pathname: pathname
      uri: "#{@prefix}:#{@id}"
      domain: 'inv'

  updateTwitterCard: ->
    app.execute 'update:twitter:card',
      title: @get('title')
      # description: @get('description')?[0..300]
      image: @get('pictures')?[0]
