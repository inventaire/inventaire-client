<script lang="ts">
  import { pluck } from 'underscore'
  import { API } from '#app/api/api'
  import app from '#app/app'
  import preq, { treq } from '#app/lib/preq'
  import { onChange } from '#app/lib/svelte/svelte'
  import { serializeEntity } from '#entities/lib/entities'
  import type { GetEntitiesByUrisResponse } from '#server/controllers/entities/by_uris_get'
  import type { TaskId } from '#server/types/task'
  import getNextTask from '#tasks/lib/get_next_task.ts'
  import { I18n } from '#user/lib/i18n'
  import TaskControls from './task_controls.svelte'
  import TaskEntity from './task_entity.svelte'

  export let taskId: TaskId
  export let entitiesType

  let task, from, to, flash, matchedTitles, noTask

  const previousTasksIds = []

  const waitForTask = getTask()

  async function getTask () {
    let promise
    if (taskId) {
      promise = assignTaskById()
    } else if (entitiesType) {
      promise = next()
    } else return
    return promise
      .catch(err => {
        flash = err
      })
  }

  async function assignTaskById () {
    const { tasks } = await preq.get(API.tasks.byIds(taskId))
    task = tasks[0]
  }

  async function next () {
    if (task) previousTasksIds.push(task._id)
    if (!entitiesType) ({ entitiesType } = task)
    const params = {
      entitiesType,
      lastTask: task,
      previousTasksIds,
    }
    const newTask = await getNextTask(params)
    if (!newTask) {
      reset()
      noTask = true
      app.navigate('/tasks/works')
      return
    }
    task = newTask
    app.navigate(`/tasks/${task._id}`)
  }

  function reset () {
    from = null
    to = null
  }

  async function updateFromAndToEntities () {
    // Nullifying `from` and `to` in order to request new claims values entities
    reset()
    if (!task || task.state === 'merged') return
    const fromUri = task.suspectUri
    const toUri = task.suggestionUri
    return treq.get<GetEntitiesByUrisResponse>(API.entities.getByUris([ fromUri, toUri ]))
      .then(assignFromToEntities(fromUri, toUri))
      .catch(err => {
        flash = err
      })
  }

  const assignFromToEntities = (fromUri, toUri) => async (entitiesRes: GetEntitiesByUrisResponse) => {
    if (areRedirects(entitiesRes)) {
      await updateTask(task._id, 'state', 'merged')
      return next()
    }
    const { entities } = entitiesRes
    from = serializeEntity(entities[fromUri])
    to = serializeEntity(entities[toUri])
  }

  async function updateTask (id, attribute, value) {
    const params = { id, attribute, value }
    return preq.put(API.tasks.update, params)
  }

  function areRedirects (entitiesRes: GetEntitiesByUrisResponse) {
    const { entities, redirects } = entitiesRes
    if (Object.keys(redirects).length === 0) return
    for (const entityUri of Object.values(redirects)) {
      if (entities[entityUri]) return true
    }
  }

  $: {
    if (task) {
      matchedTitles = pluck(task.externalSourcesOccurrences, 'matchedTitles').flat()
    }
  }
  $: isMerged = task && task.state === 'merged'
  $: onChange(task, updateFromAndToEntities)
</script>
{#if noTask}
  <p id="no-task" class="grey">
    {I18n('no task available, this is fine')}
  <p />
{:else}
  <div class="entities-section">
    <div class="from-entity">
      <h2>From</h2>
      {#if from}
        <TaskEntity
          entity={from}
          {matchedTitles}
        />
      {/if}
    </div>
    <div class="to-entity">
      <h2>To</h2>
      {#if to}
        <TaskEntity
          entity={to}
          {matchedTitles}
        />
      {/if}
    </div>
  </div>
  {#if isMerged}
    <div class="error-wrapper">
      <pre>{JSON.stringify(task, null, 2)}</pre>
    </div>
  {/if}
  {#await waitForTask then}
    <TaskControls
      {task}
      {from}
      {to}
      {flash}
      on:next={next}
    />
  {/await}
  <!-- CSS hack to not let sticky .controls overflow the bottom of task-entity -->
  <!-- Needed since .controls has a dynamic height (due to .sources-links length). -->
  <div class="placeholder" />
{/if}
<style lang="scss">
  @import "#general/scss/utils";
  #no-task{
    @include display-flex(row, center, center);
    padding: 3em;
  }
  .entities-section{
    @include display-flex(row, flex-start, flex-start);
    background-color: #ddd;
  }
  .from-entity{
    flex: 1 0 0;
  }
  .to-entity{
    min-height: 100vh;
    background-color: $light-grey;
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
  .placeholder{
    height: 6em;
  }
</style>
