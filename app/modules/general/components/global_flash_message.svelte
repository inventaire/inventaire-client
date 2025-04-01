<script lang="ts">
  import { API } from '#app/api/api'
  import { icon } from '#app/lib/icons'
  import preq from '#app/lib/preq'
  import { commands } from '#app/radio'
  import { I18n } from '#user/lib/i18n'

  let intervalId = null
  let active = false

  function showNetworkError () {
    if (active) return
    active = true
    if (intervalId == null) intervalId = setInterval(checkState, 1000)
  }

  function hideNetworkError () {
    if (!active) return
    active = false
    if (intervalId != null) {
      clearInterval(intervalId)
      intervalId = null
    }
  }

  const checkState = () => preq.get(API.tests).then(hideNetworkError)

  commands.setHandlers({
    'flash:message:show:network:error': showNetworkError,
  })
</script>

<div class="global-flash-message" title={I18n('offline_help')} class:active>
  {@html icon('bolt')}
  <span>{I18n('you are offline')}</span>
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .global-flash-message{
    background-color: $success-color;
    @include radius(3px);
    padding: 0.8em 1em;
    margin: 1em;
    color: white;
    @include display-flex(row, center, center);
    @include position(fixed, -10em, 0, null, null, 100);
    @include transition(top);
    &.active{
      background-color: $warning-color;
      inset-block-start: 0;
    }
    &:not(.active){
      display: none;
    }
  }
  /* Very small screens */
  @media screen and (width < $very-small-screen){
    .global-flash-message{
      inset-inline-start: 0;
      &.active{
        inset-block-start: auto;
        inset-block-end: 0;
      }
    }
  }
</style>
