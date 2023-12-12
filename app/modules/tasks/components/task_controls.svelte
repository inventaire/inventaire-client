<script>
  import { clone } from 'underscore'
  import preq from '#lib/preq'
  import { I18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import { createEventDispatcher } from 'svelte'
  import { autofocus } from '#lib/components/actions/autofocus'
  import Spinner from '#general/components/spinner.svelte'
  import TaskInfo from './task_info.svelte'
  import TaskScores from './task_scores.svelte'
  import mergeEntities from '#entities/views/editor/lib/merge_entities'
  import { onChange } from '#lib/svelte/svelte'
  import Flash from '#lib/components/flash.svelte'

  const dispatch = createEventDispatcher()

  export let task, from, to, flash

  let merging

  function handleKeydown (event) {
    if (event.altKey || event.ctrlKey || event.shiftKey || event.metaKey) return
    if (event.key === 's') mergeTaskEntities({ isToFrom: true })
    if (event.key === 'm') mergeTaskEntities()
    if (event.key === 'd') dismiss()
    else if (event.key === 'n') dispatch('next')
  }

  function mergeTaskEntities ({ isToFrom }) {
    if (!(from && to)) return
    merging = true
    const toUri = clone(to.uri)
    const fromUri = clone(from.uri)
    // Optimistic UI: go to the next candidates without waiting for the merge confirmation
    dispatch('next')
    const params = isToFrom ? [ toUri, fromUri ] : [ fromUri, toUri ]
    mergeEntities(...params)
      .catch(err => {
        flash = err
      })
      .finally(() => merging = false)
  }

  function dismiss () {
    return preq.put(app.API.tasks.update, {
      id: task._id,
      attribute: 'state',
      value: 'dismissed'
    })
      .then(() => dispatch('next'))
  }

  $: {
    if (task && task.state === 'merged') {
      flash = new Error(I18n('this task has already been treated'))
    }
  }
  $: onChange(task, () => { flash = null })
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
      {#if merging}<Spinner light={true} />{/if}
      <button
        class="merge dangerous-button"
        disabled={!(from && to)}
        title={from?.uri && to?.uri ? `merge ${from?.uri} into ${to?.uri}\nShortkey: m` : 'Shortkey: m'}
        on:click={mergeTaskEntities}
      >
        {@html icon('compress')}{I18n('merge')}
      </button>
      <button
        class="swap dangerous-button"
        disabled={!(from && to)}
        title="Merge to into from. Shortkey: s"
        on:click={() => mergeTaskEntities({ isToFrom: true })}
      >
        {@html icon('exchange')}{I18n('swap & merge')}
      </button>
      <button
        class="dismiss grey-button"
        title="Archive this task. Shortkey: d"
        on:click={dismiss}
      >
        {@html icon('close')}{I18n('dismiss')}
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
    margin-block-start: 0.3em;
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
