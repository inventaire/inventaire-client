<script>
  import { icon } from '#lib/utils'
  import { I18n } from '#user/lib/i18n'
  import { createEventDispatcher } from 'svelte'
  const dispatch = createEventDispatcher()
</script>

<div class="display-mode-button">
  <button
    class="tiny-button light-blue"
    on:click={() => dispatch('edit')}
  >
    {@html icon('pencil')}
    <span>{I18n('edit')}</span>
  </button>
</div>

<style lang="scss">
  @import '#general/scss/utils';
  button{
    max-height: 2.5em;
    font-weight: normal;
  }
  /*Small screens*/
  @media screen and (max-width: $smaller-screen) {
    button{
      padding: 0.3em 0.5em;
      margin: 0.2em;
    }
  }
  /*Large screens*/
  @media screen and (min-width: $smaller-screen) {
    .display-mode-button{
      height: 2.5rem;
    }
    button{
      margin-left: 0.5em;
      height: 100%;
      @include shy-button-label;
    }
  }
</style>
