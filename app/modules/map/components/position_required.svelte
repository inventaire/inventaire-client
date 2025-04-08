<script lang="ts">
  import { icon } from '#app/lib/icons'
  import UserPositionPicker from '#settings/components/user_position_picker.svelte'
  import { i18n, I18n } from '#user/lib/i18n'

  let showPositionPicker
</script>

<div class="position-required">
  {@html icon('map-marker')}
  <p class="requesting-position">
    {I18n('setting a position is required for this action')}
  </p>
  <button
    class="button light-blue"
    on:click={() => showPositionPicker = true}
  >
    {@html icon('map-marker')}
    {I18n('edit your position')}
  </button>
  <p class="tip">{i18n('position_privacy_context')}</p>
  <p class="tip">{i18n('position_privacy_tip')}</p>
</div>

<UserPositionPicker bind:showPositionPicker />

<style lang="scss">
  @use "#general/scss/utils";
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
  /* Large screens */
  @media screen and (width >= $small-screen){
    .position-required{
      > :global(.fa-map-marker){
        margin-block-start: 2rem;
      }
    }
    button{
      margin-block-start: 4em;
    }
  }
</style>
