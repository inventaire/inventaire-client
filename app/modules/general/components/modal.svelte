<script>
  import getActionKey from '#lib/get_action_key'
  import { icon } from '#lib/handlebars_helpers/icons'
  import { I18n } from '#user/lib/i18n'
  import { createEventDispatcher, onDestroy, onMount } from 'svelte'
  import { autofocus } from '#lib/components/actions/autofocus'

  const dispatch = createEventDispatcher()
  const close = () => dispatch('closeModal')

  function onKeyUp (e) {
    const key = getActionKey(e)
    if (key === 'esc') close()
  }

  onMount(() => app.vent.trigger('overlay:shown'))
  onDestroy(() => app.vent.trigger('overlay:hidden'))
</script>

<div class="modal-overlay"
  on:click={close}
  on:keyup={onKeyUp}
  use:autofocus={{ refocusOnVisibilityChange: false }}
  tabindex="0"
>
  <!-- stopPropagation so that only clicks on overlay trigger a close -->
  <div class="modal-outer" on:click|stopPropagation>
    <div class="modal-inner"><slot /></div>
    <button
      class="close"
      title={I18n('close')}
      on:click={close}
      >
      {@html icon('close')}
    </button>
  </div>
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .modal-overlay{
    background: rgba(black, 0.55);
    overflow: auto;
    @include position(fixed, 0, 0, 0, 0);
    // Above the dropdown
    z-index: 20;
    @include display-flex(row, baseline, center);
    overflow-y: auto;
  }
  .modal-outer{
    padding: 1em;
    position: relative;
    background-color: white;
    @include radius;
    margin: 1em 0;
    flex: 0 0 auto;
  }
  .close{
    position: absolute;
    top: 0.2em;
    right: 0;
    margin: 0;
    padding: 0;
    font-size: 1.5rem;
    @include text-hover($grey, $dark-grey);
  }
  /*Large screens*/
  @media screen and (min-width: $small-screen) {
    .modal-inner{
      min-width: 10em;
      margin: 1em;
    }
  }
  /*Small screens*/
  @media screen and (max-width: $small-screen) {
    .modal-inner{
      min-width: 10em;
      margin: 1em 0;
    }
  }
</style>
