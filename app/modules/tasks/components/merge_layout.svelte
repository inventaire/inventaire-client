<script lang="ts">
  import { createEventDispatcher } from 'svelte'
  import { clone, pluck } from 'underscore'
  import { API } from '#app/api/api'
  import { icon } from '#app/lib/icons'
  import { treq } from '#app/lib/preq'
  import { BubbleUpComponentEvent, onChange } from '#app/lib/svelte/svelte'
  import { serializeEntity } from '#entities/lib/entities'
  import { mergeEntities } from '#entities/views/editor/lib/merge_entities'
  import Spinner from '#general/components/spinner.svelte'
  import type { GetEntitiesByUrisResponse } from '#server/controllers/entities/by_uris_get'
  import type { EntityUri } from '#server/types/entity'
  import { areRedirects, updateTask } from '#tasks/components/lib/tasks_helpers'
  import { I18n } from '#user/lib/i18n'
  import TaskControls from './task_controls.svelte'
  import TaskEntity from './task_entity.svelte'

  export let task

  const dispatch = createEventDispatcher()
  const bubbleUpEvent = BubbleUpComponentEvent(dispatch)

  let from, to, flash, matchedTitles, areBothInvEntities, waitingForEntities, merging
  $: fromUri = task?.suspectUri
  $: toUri = task?.suggestionUri

  async function updateFromAndToEntities () {
    if (!task || task.state === 'processed') return
    waitingForEntities = treq.get<GetEntitiesByUrisResponse>(API.entities.getByUris([ fromUri, toUri ]))
      .then(updateTaskAndAssignFromToEntities(fromUri, toUri))
      .catch(err => {
        flash = err
      })
  }

  const updateTaskAndAssignFromToEntities = (fromUri, toUri) => async (entitiesRes: GetEntitiesByUrisResponse) => {
    const { entities, redirects } = entitiesRes
    if (areRedirects(entities, redirects)) {
      await updateTask(task._id, 'state', 'processed')
      return dispatch('next')
    }
    areBothInvEntities = isInvEntityUri(fromUri) && isInvEntityUri(toUri)

    assignFromToEntities(fromUri, toUri, entities)
  }

  function isInvEntityUri (uri) {
    return uri.split(':')[0] === 'inv'
  }

  const assignFromToEntities = (fromUri, toUri, entities) => {
    from = serializeEntity(entities[fromUri])
    to = serializeEntity(entities[toUri])
  }

  function exchangeFromTo () {
    const tmpFrom = clone(from)
    from = to
    to = tmpFrom
  }

  async function mergeTaskEntities () {
    if (!(from && to)) return
    merging = true
    // Optimistic UI: go to the next candidates without waiting for the merge confirmation
    dispatch('next')
    const params: [ EntityUri, EntityUri ] = [ from.uri, to.uri ]
    await mergeEntities(...params)
      .catch(err => {
        flash = err
      })
      .finally(() => merging = false)
  }

  $: {
    if (task) {
      matchedTitles = pluck(task.externalSourcesOccurrences, 'matchedTitles').flat()
    }
  }
  $: processedTask = task && task.state && task.state !== undefined
  $: onChange(task, updateFromAndToEntities)
</script>
{#await waitingForEntities}
  <span class="loading"><Spinner /></span>
{/await}
{#if !processedTask}
  <div class="entities-section">
    <div class="from-entity">
      <h2>From</h2>
      {#key from}
        <TaskEntity
          entity={from}
          {matchedTitles}
        />
      {/key}
    </div>
    {#if areBothInvEntities}
      <button
        class="swap"
        on:click={exchangeFromTo}
        title={I18n('swap from and to entities')}
      >
        {@html icon('exchange')}
      </button>
    {/if}
    <div class="to-entity">
      <h2>To</h2>
      {#key to}
        <TaskEntity
          entity={to}
          {matchedTitles}
        />
      {/key}
    </div>
  </div>
{:else}
  <div class="error-wrapper">
    <pre>{JSON.stringify(task, null, 2)}</pre>
  </div>
{/if}
<TaskControls
  {task}
  {flash}
  actionTitle={`Merge "${from?.label}" into "${to?.label}"\nShortkey: m`}
  on:action={mergeTaskEntities}
  on:next={bubbleUpEvent}
  bind:doingAction={merging}
  {processedTask}
/>
<style lang="scss">
  @import "#general/scss/utils";
  .entities-section{
    @include display-flex(row, flex-start, flex-start);
    background-color: #ddd;
  }
  .from-entity{
    min-height: 100vh;
    padding-inline-start: 1em;
    flex: 1 0 0;
  }
  .to-entity{
    min-height: 100vh;
    background-color: $light-grey;
    padding-inline-start: 1em;
    flex: 1 0 0;
  }
  h2{
    @include display-flex(row, null, center);
    @include sans-serif;
    font-size: 1.2rem;
    margin: 0;
    padding-block-start: 0.3em;
  }
  .error-wrapper{
    background-color: $light-grey;
    max-width: 40em;
    margin: 1em auto;
    padding: 1em;
  }
  .swap{
    position: relative;
    inset-inline-start: 1.3em;
    inset-block-start: 30vh;
    background-color: white;
    padding: 0.5em;
    border-radius: 50%;
  }
  .loading{
    position: absolute;
    margin: 0 auto;
    padding-block-start: 0.5em;
    width: 100%;
  }
</style>
