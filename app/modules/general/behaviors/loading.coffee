module.exports = class Loading extends Marionette.Behavior
  ui:
    loading: ".loading, .check"

  events:
    'loading': 'showSpinningLoader'
    'stopLoading': 'hideSpinningLoader'
    'somethingWentWrong': 'somethingWentWrong'

  showSpinningLoader: (e, params)->
    @$target = @getTarget(params)

    body = "<i class='fa fa-circle-o-notch fa-spin'></i>"
    if params?.message?
      mes = params.message
      body += "<p class='grey'>#{mes}</p>"

    @$target.html body

    timeout = params?.timeout or 16
    unless timeout is 'none'
      cb = => @somethingWentWrong.apply @, [null, params]
      setTimeout cb, timeout * 1000

  hideSpinningLoader: (e, params)->
    @$target.empty()
    @hidden = true

  somethingWentWrong: (e, params)->
    unless @hidden
      @$target or= this.getTarget(params)

      oups = _.i18n 'Something went wrong'
      body = "<i class='fa fa-bolt'></i><p> #{oups} :(</p>"

      @$target.html body

  getTarget: (params)->
    if params?.selector? then $(params.selector).find('.loading')
    else @ui.loading

