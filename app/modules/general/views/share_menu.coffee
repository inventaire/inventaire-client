behaviorsPlugin = require 'modules/general/plugins/behaviors'
{ host } = require 'lib/urls'

module.exports = Marionette.ItemView.extend
  template: require './templates/share_menu'
  className: 'shareMenu'
  initialize: ->
    @href =  encodeURIComponent host + document.location.pathname
    @title =  encodeURIComponent document.title
  onShow: -> app.execute 'modal:open'

  serializeData: ->
    facebookUrl: @getFacebookUrl()
    twitterUrl: @getTwitterUrl()
    tumblrUrl: @getTumblrUrl()

  getFacebookUrl: ->
    "https://www.facebook.com/dialog/share?app_id=1383915125249576&href=#{@href}&caption=Inventaire&redirect_uri=#{@href}"

  getTwitterUrl: ->
    "https://twitter.com/intent/tweet?text=#{@title}&url=#{@href}&via=inventaire_io"

  getTumblrUrl: ->
    "https://www.tumblr.com/widgets/share/tool?canonicalUrl=&url=#{@href}"
