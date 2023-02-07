<script>
  import { i18n, I18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import Alertbox from '#general/components/alertbox.svelte'
  import { createEventDispatcher } from 'svelte'
  import { autofocus } from '#lib/components/actions/autofocus'
  import _ from 'underscore'
  import EntityPreview from './entity_preview.svelte'
  import Spinner from '#general/components/spinner.svelte'

  const dispatch = createEventDispatcher()
  const lazyDispatchFilter = _.debounce(dispatch.bind(null, 'filter'), 200)

  export let entity, error, from, to, candidates, index, merging

  function handleKeydown (event) {
    if (event.altKey || event.ctrlKey || event.shiftKey || event.metaKey) return
    if (event.target.tagName === 'INPUT' || event.target.tagName === 'TEXTAREA') return

    if (event.key === 'm') dispatch('merge')
    else if (event.key === 'n') dispatch('next')
    else if (event.key === 'r') dispatch('reset')
  }

  $: remainingCandidates = candidates && index + 1 <= candidates.length
</script>

<svelte:window on:keydown={handleKeydown} />

<div class="controls" tabindex="-1" use:autofocus>
  <div class="buttons-wrapper">
    <div class="entity">
      {#if entity}<EntityPreview {entity} large={true} />{/if}
    </div>
    <div class="center">
      <input
        type="text"
        name="filter"
        placeholder={i18n('filter')}
        title={i18n('the filter can be a regular expression')}
        on:keyup={event => lazyDispatchFilter(event.target.value)}
      />
      <button
        class="merge dangerous-button"
        disabled={!(from && to)}
        title={from?.uri && to?.uri ? `merge ${from?.uri} into ${to?.uri}\nShortkey: m` : 'Shortkey: m'}
        on:click={() => dispatch('merge')}
      >
        {@html icon('compress')}{I18n('merge')}
        {#if merging}<Spinner light={true} />{/if}
      </button>
      {#if remainingCandidates}
        <button
          class="next light-blue-button"
          title="Shortkey: n"
          on:click={() => dispatch('next')}
        >
          {@html icon('arrow-right')}{I18n('next')}
        </button>
      {/if}
    </div>
    <div class="status">
      {#if remainingCandidates}
        <p>candidates: {index + 1} / {candidates.length}</p>
        <button
          class="skip"
          on:click={() => dispatch('skip')}>{I18n('skip')}
        </button>
      {/if}
      <button
        class="reset"
        title="Shortkey: r"
        on:click={() => dispatch('reset')}>{I18n('reset')}
      </button>
    </div>
  </div>
  <div class="alerts">
    {#if error}<Alertbox {error} on:closed={() => error = null} />{/if}
  </div>
</div>

<style lang="scss">
  @import "#general/scss/utils";

  .controls{
    background-color: #bbb;
    position: fixed;
    bottom: 0;
    right: 0;
    left: 0;
    padding: 0.5em;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: stretch;
  }

  :disabled{
    cursor: not-allowed;
    opacity: 0.3;
  }

  .buttons-wrapper, .alerts, .center{
    display: flex;
    flex-direction: row;
    align-items: center;
    justify-content: space-between;
  }

  input{
    margin-bottom: 0;
    margin-right: 1em;
    max-width: 20em;
  }

  button{
    margin: 0 0.5em;
    white-space: nowrap;
    font-family: $sans-serif;
  }

  .alerts{
    align-self: stretch;
    min-width: 50%;
    max-width: 30em;
    margin: 0 auto;
    background-color: $soft-red;
  }

  /* Small screens */
  @media screen and (max-width: 800px){
    .entity, .status{
      display: none;
    }
  }

  /* Large screens */
  @media screen and (min-width: 800px){
    .entity, .status{
      // Make sure to push the center in the same proportion, to keep it in the center
      min-width: 20em;
    }
    .status{
      display: flex;
      flex-direction: row;
      justify-content: flex-end;
      p{
        padding: 0.2em 0.5em;
        background-color: $light-grey;
        white-space: nowrap;
      }
    }
  }
</style>
