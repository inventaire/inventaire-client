<script>
  import { createEventDispatcher } from 'svelte'
  import _ from 'underscore'
  import { autofocus } from '#lib/components/actions/autofocus'
  import Flash from '#lib/components/flash.svelte'
  import { icon } from '#lib/icons'
  import { i18n, I18n } from '#user/lib/i18n'
  import EntityPreview from './entity_preview.svelte'

  const dispatch = createEventDispatcher()
  const lazyDispatchFilter = _.debounce(dispatch.bind(null, 'filter'), 200)

  export let entity, flash, from, to, candidates, index

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
        <button
          class="reset"
          title="Shortkey: r"
          on:click={() => dispatch('reset')}>{I18n('reset')}
        </button>
      {/if}
    </div>
  </div>
  {#if flash}
    <div class="alerts">
      <Flash bind:state={flash} />
    </div>
  {/if}
</div>

<style lang="scss">
  @import "#general/scss/utils";

  .controls{
    background-color: #bbb;
    position: fixed;
    inset-block-end: 0;
    inset-inline: 0;
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
    margin-block-end: 0;
    margin-inline-end: 1em;
    max-inline-size: 20em;
  }

  button{
    margin: 0 0.5em;
    white-space: nowrap;
    font-family: $sans-serif;
  }

  .alerts{
    align-self: stretch;
    min-inline-size: 50%;
    max-inline-size: 30em;
    margin: 0 auto;
  }

  /* Small screens */
  @media screen and (width < 800px){
    .entity, .status{
      display: none;
    }
  }

  /* Large screens */
  @media screen and (width >= 800px){
    .entity, .status{
      // Make sure to push the center in the same proportion, to keep it in the center
      min-inline-size: 20em;
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
