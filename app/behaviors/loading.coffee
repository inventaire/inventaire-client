module.exports = class Loading extends Marionette.Behavior
  ui:
    loading: ".loading"

  events:
    "loading": "showSpinningLoader"
    "stopLoading": "hideSpinningLoader"

  showSpinningLoader: (e, params)->
    _.log params, 'showSpinningLoader params'
    if params?.selector?
      $target = $(params.selector).find('.loading')
    else
      $target = @ui.loading

    body = "<i class='fa fa-circle-o-notch fa-spin'></i>"
    if params?.message?
      mes = params.message
      body += "<p class='grey'>#{mes}</p>"

    $target.html body

  hideSpinningLoader: ->
    @ui.loading.empty()

