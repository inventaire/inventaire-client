module.exports = class Loading extends Marionette.Behavior
  ui:
    loading: ".loading"

  events:
    "loading": "showSpinningLoader"
    "stopLoading": "hideSpinningLoader"

  showSpinningLoader: (e, params)->
    if params.selector?
      $target = $(params.selector).find('.loading')
    else
      $target = @ui.loading
    $target.html "<i class='fa fa-circle-o-notch fa-spin'></i>"

  hideSpinningLoader: ->
    @ui.loading.empty()

