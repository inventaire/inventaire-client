<script>
  import { i18n, I18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import { showMainUserPositionPicker } from '#map/lib/map'
</script>

<div class="position-required">
  {@html icon('map-marker')}
  <p class="requesting-position">
    {I18n('setting a position is required for this action')}
  </p>
  <button
    class="button light-blue"
    on:click={showMainUserPositionPicker}
  >
    {@html icon('map-marker')}
    {I18n('edit your position')}
  </button>
  <p class="tip">{i18n('position_privacy_context')}</p>
  <p class="tip">{i18n('position_privacy_tip')}</p>
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .position-required{
    @include display-flex(column, center, center);
    margin: 2em auto;
    max-width: 40em;
    > :global(.fa-map-marker){
      font-size: 5em;
      color: $grey;
    }
  }
  button{
    margin: 1em;
  }
  .requesting-position{
    font-size: 1.2em;
    text-align: center;
  }
  .tip{
    color: $grey;
    text-align: center;
    margin: 1em;
  }
  /*Large screens*/
  @media screen and (min-width: $small-screen) {
    .position-required{
      > :global(.fa-map-marker){
        margin-top: 2rem;
      }
    }
    button{
      margin-top: 4em;
    }
  }
</style>
