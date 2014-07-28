module.exports = class Loading extends Marionette.Behavior
  ui:
    loading: ".loading"

  events:
    "loading": "showSpinningLoader"
    "stopLoading": "hideSpinningLoader"

  showSpinningLoader: ->
    @ui.loading
    .html "<i class='fa fa-circle-o-notch fa-spin'></i>"

  hideSpinningLoader: ->
    @ui.loading.empty()

