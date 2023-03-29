<script>
  import { I18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import Alertbox from '#general/components/alertbox.svelte'
  import { createEventDispatcher } from 'svelte'
  import { autofocus } from '#lib/components/actions/autofocus'
  import Spinner from '#general/components/spinner.svelte'
  import TaskInfo from './task_info.svelte'
  import TaskScores from './task_scores.svelte'
  import mergeEntities from '#entities/views/editor/lib/merge_entities'
  import { onChange } from '#lib/svelte/svelte'

  const dispatch = createEventDispatcher()

  export let task, from, to, error

  let merging

  function handleKeydown (event) {
    if (event.altKey || event.ctrlKey || event.shiftKey || event.metaKey) return
    if (event.key === 'm') mergeTaskEntities()
    else if (event.key === 'n') dispatch('next')
  }

  function mergeTaskEntities () {
    if (!(from && to)) return
    merging = true
    mergeEntities(from.uri, to.uri)
      .then(() => dispatch('next'))
      .catch(err => {
        error = err
      })
      .finally(() => merging = false)
  }

  $: {
    if (task && task.state === 'merged') {
      error = { message: I18n('this task has already been treated') }
    }
  }
  $: onChange(task, () => { error = null })
</script>

<svelte:window on:keydown={handleKeydown} />
<div class="controls" tabindex="-1" use:autofocus>
  <div class="buttons-wrapper">
    <ul class="task-scores">
      {#if task.entitiesType === 'work'}
        <TaskInfo {task} />
      {:else}
        <TaskScores {task} />
      {/if}
    </ul>
    <div class="actions">
      <button
        class="merge dangerous-button"
        disabled={!(from && to)}
        title={from?.uri && to?.uri ? `merge ${from?.uri} into ${to?.uri}\nShortkey: m` : 'Shortkey: m'}
        on:click={mergeTaskEntities}
      >
        {@html icon('compress')}{I18n('merge')}
        {#if merging}<Spinner light={true} />{/if}
      </button>
      <button
        class="next light-blue-button"
        title="Shortkey: n"
        on:click={() => dispatch('next')}
      >
        {@html icon('arrow-right')}{I18n('next')}
      </button>
    </div>
  </div>
  {#if error}
    <div class="alerts">
      <Alertbox {error} on:closed={() => error = null} />
    </div>
  {/if}
</div>

<style lang="scss">
  @import "#general/scss/utils";
  .controls{
    background-color: #bbb;
    position: fixed;
    bottom: 0;
    right: 0;
    left: 0;
    padding: 0.3em;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: stretch;
  }

  :disabled{
    cursor: not-allowed;
    opacity: 0.3;
  }

  .task-scores{
    background-color: white;
    padding: 0.3em 0.5em;
  }

  .buttons-wrapper, .alerts, .actions{
    @include display-flex(row, center, space-between);
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
    margin-top: 0.3em;
  }

  /* Smaller screens */
  @media screen and (max-width: $smaller-screen){
    .actions{
      @include display-flex(column);
      button{
        margin: 0.3em 0;
        width: 100%;
      }
    }
  }
</style>
