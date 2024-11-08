<script lang="ts">
  import { createEventDispatcher } from 'svelte'
  import { API } from '#app/api/api'
  import preq, { treq } from '#app/lib/preq'
  import { onChange, BubbleUpComponentEvent } from '#app/lib/svelte/svelte'
  import { serializeEntity } from '#entities/lib/entities'
  import Spinner from '#general/components/spinner.svelte'
  import type { GetEntitiesByUrisResponse } from '#server/controllers/entities/by_uris_get'
  import { areRedirects, updateTask } from '#tasks/components/lib/tasks_helpers.ts'
  import TaskControls from './task_controls.svelte'
  import TaskEntity from './task_entity.svelte'

  export let task
  export let entitiesType, type

  const dispatch = createEventDispatcher()
  const bubbleUpEvent = BubbleUpComponentEvent(dispatch)

  let entity, flash, waitingForEntity, deleting
  $: uri = task?.suspectUri

  async function getAndAssignEntity () {
    if (!task || task.state === 'merged') return
    waitingForEntity = treq.get<GetEntitiesByUrisResponse>(API.entities.getByUris(uri))
      .then(updateTaskAndAssignEntity)
      .catch(err => {
        flash = err
      })
  }

  async function updateTaskAndAssignEntity (entitiesRes: GetEntitiesByUrisResponse) {
    const { entities, redirects } = entitiesRes
    if (areRedirects(entities, redirects)) {
      await updateTask(task._id, 'state', 'merged')
      return dispatch('next')
    }
    entity = serializeEntity(entities[uri])
  }

  async function deleteTaskEntity () {
    deleting = true
    // Optimistic UI: go to the next candidates without waiting for the merge confirmation
    dispatch('next')
    await preq.post(API.entities.delete, { uris: [ uri ] })
      .catch(err => {
        flash = err
      })
      .finally(() => deleting = false)
  }

  $: treatedTask = task && task.state && task.state !== undefined
  $: onChange(uri, getAndAssignEntity)
</script>
{#await waitingForEntity}
  <span class="loading"><Spinner /></span>
{/await}
{#if !treatedTask}
  <div class="entity">
    {#key entity}
      <TaskEntity {entity} />
    {/key}
  </div>
{:else}
  <div class="error-wrapper">
    <pre>{JSON.stringify(task, null, 2)}</pre>
  </div>
{/if}
<TaskControls
  {task}
  {flash}
  actionTitle={`Delete "${entity?.label}"\nShortkey: d`}
  on:action={deleteTaskEntity}
  on:next={bubbleUpEvent}
  bind:doingAction={deleting}
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
