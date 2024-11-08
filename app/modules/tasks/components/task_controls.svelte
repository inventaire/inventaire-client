<script lang="ts">
  import { createEventDispatcher } from 'svelte'
  import { API } from '#app/api/api'
  import { isNonEmptyArray } from '#app/lib/boolean_tests'
  import { autofocus } from '#app/lib/components/actions/autofocus'
  import Flash from '#app/lib/components/flash.svelte'
  import { icon } from '#app/lib/icons'
  import preq from '#app/lib/preq'
  import { onChange } from '#app/lib/svelte/svelte'
  import Spinner from '#general/components/spinner.svelte'
  import { I18n } from '#user/lib/i18n'
  import TaskInfo from './task_info.svelte'
  import TaskScores from './task_scores.svelte'

  const dispatch = createEventDispatcher()

  export let task, flash, doingAction, actionTitle

  function handleKeydown (event) {
    if (event.altKey || event.ctrlKey || event.shiftKey || event.metaKey) return
    if (task.type === 'delete') {
      if (event.key === 'd') dispatch('action')
    } else {
      if (event.key === 'm') dispatch('action')
    }
    if (event.key === 'a') dismiss()
    else if (event.key === 'n') dispatch('next')
  }

  function dismiss () {
    return preq.put(API.tasks.update, {
      id: task._id,
      attribute: 'state',
      value: 'dismissed',
    })
      .then(() => dispatch('next'))
  }

  $: treatedTask = task && task.state
  $: onChange(task, () => { flash = null })
  $: {
    if (treatedTask) {
      flash = {
        type: 'error',
        message: I18n('this task has already been treated'),
      }
    }
  }
</script>

<svelte:window on:keydown={handleKeydown} />
<div class="controls" tabindex="-1" use:autofocus>
  <div class="buttons-wrapper">
    <div class="task-info-section">
      {#if !treatedTask}
        {#if isNonEmptyArray(task.reporters)}
          <ul class="task-info">
            <TaskInfo {task} />
          </ul>
        {/if}
        {#if task.externalSourcesOccurrences}
          <ul class="task-info">
            <TaskScores {task} />
          </ul>
        {/if}
      {/if}
    </div>
    <div class="actions">
      {#if doingAction}<Spinner light={true} />{/if}
      <button
        class="merge dangerous-button"
        title={actionTitle}
        disabled={treatedTask}
        on:click={() => dispatch('action')}
      >
        {#if task.type === 'delete'}
          {@html icon('trash')}{I18n('delete')}
        {:else}
          {@html icon('compress')}{I18n('merge')}
        {/if}
      </button>
      <button
        class="dismiss grey-button"
        title={I18n('Archive this task. Shortkey: a')}
        disabled={treatedTask}
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
    <div class="flash">
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

  .task-info{
    background-color: white;
    padding: 0.3em 0.5em;
    margin: 0 0.5em;
  }

  .task-info-section{
    @include display-flex(row, center, space-between);
  }

  .buttons-wrapper, .flash, .actions{
    @include display-flex(row, center, space-between);
  }

  button{
    margin: 0 0.5em;
    white-space: nowrap;
    font-family: $sans-serif;
  }

  .flash{
    margin: 0 auto;
  }

  /* Smaller screens */
  @media screen and (width < $smaller-screen){
    .actions{
      @include display-flex(column);
      margin-inline-start: 0.5em;
      button{
        margin: 0.3em 0;
        width: 100%;
      }
    }
  }
</style>
