<script lang="ts">
  import { clone, pluck, values } from 'underscore'
  import { API } from '#app/api/api'
  import app from '#app/app'
  import { icon } from '#app/lib/icons'
  import preq, { treq } from '#app/lib/preq'
  import { onChange } from '#app/lib/svelte/svelte'
  import { serializeEntity } from '#entities/lib/entities'
  import Spinner from '#general/components/spinner.svelte'
  import type { GetEntitiesByUrisResponse } from '#server/controllers/entities/by_uris_get'
  import type { TaskId } from '#server/types/task'
  import { getNextTask } from '#tasks/lib/get_next_task.ts'
  import { I18n } from '#user/lib/i18n'
  import TaskControls from './task_controls.svelte'
  import TaskEntity from './task_entity.svelte'

  export let taskId: TaskId
  export let entitiesType

  let task, from, to, flash, matchedTitles, areBothInvEntities, waitingForEntities
  $: fromUri = task?.suspectUri
  $: toUri = task?.suggestionUri

  const previousTasksIds = []

  const waitForTask = getTask()

  async function getTask () {
    const promise = taskId ? taskById() : nextTask()
    return promise
      .catch(err => {
        flash = err
      })
  }

  async function taskById () {
    const { tasks } = await preq.get(API.tasks.byIds(taskId))
    task = tasks[0]
  }

  async function nextTask () {
    if (task) previousTasksIds.push(task._id)
    if (!entitiesType) ({ entitiesType } = task)
    const params = {
      entitiesType,
      lastTask: task,
      previousTasksIds,
    }
    const newTask = await getNextTask(params)
    if (!newTask) {
      return resetTaskLayout()
    }
    task = newTask
    app.navigate(`/tasks/${task._id}`)
  }

  function resetTaskLayout () {
    app.navigate('/tasks')
    task = null
    from = null
    to = null
  }

  async function updateFromAndToEntities () {
    if (!task || task.state === 'merged') return
    waitingForEntities = treq.get<GetEntitiesByUrisResponse>(API.entities.getByUris([ fromUri, toUri ]))
      .then(updateTaskAndAssignFromToEntities(fromUri, toUri))
      .catch(err => {
        flash = err
      })
  }

  const updateTaskAndAssignFromToEntities = (fromUri, toUri) => async (entitiesRes: GetEntitiesByUrisResponse) => {
    const { entities, redirects } = entitiesRes
    if (areRedirects(entities, redirects)) {
      await updateTask(task._id, 'state', 'merged')
      return nextTask()
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

  async function updateTask (id, attribute, value) {
    const params = { id, attribute, value }
    return preq.put(API.tasks.update, params)
  }

  function areRedirects (entities, redirects) {
    if (Object.keys(redirects).length === 0) return
    for (const entityUri of values(redirects)) {
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
{#await waitForTask then}
  {#if task}
    {#await waitingForEntities}
      <span class="loading"><Spinner /></span>
    {/await}
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
    {#if isMerged}
      <div class="error-wrapper">
        <pre>{JSON.stringify(task, null, 2)}</pre>
      </div>
    {/if}
    <TaskControls
      {task}
      {from}
      {to}
      {flash}
      on:next={nextTask}
    />
  {:else}
    <p id="no-task" class="grey">
      {I18n('no task available, this is fine')}
    </p>
  {/if}
{/await}
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
