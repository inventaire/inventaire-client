# build the endpoints routes
root = '/api'
module.exports = (name)->
  public: "#{root}/#{name}/public"
  authentified: "#{root}/#{name}"
