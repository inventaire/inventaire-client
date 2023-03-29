<script>
  import app from '#app/app'
  import preq from '#lib/preq'
  import { onChange } from '#lib/svelte/svelte'
  import { serializeEntity } from '#entities/lib/entities'
  import TaskControls from './task_controls.svelte'
  import TaskEntity from './task_entity.svelte'
  import getNextTask from '#tasks/lib/get_next_task.js'
  import { pluck } from 'underscore'
  import { I18n } from '#user/lib/i18n'

  export let taskId, entitiesType

  let task, from, to, error, matchedTitles, noTask

  let previousTasksIds = []

  const waitForTask = getTask()

  async function getTask () {
    let promise
    if (taskId) {
      promise = assignTaskById(taskId)
    } else if (entitiesType) {
      promise = next()
    } else return
    return promise
      .then(updateFromAndToEntities)
      .catch(err => {
        error = err
      })
  }

  async function assignTaskById () {
    const { tasks } = await preq.get(app.API.tasks.byIds(taskId))
    task = tasks[0]
  }

  async function next () {
    if (task) previousTasksIds.push(task._id)
    if (!entitiesType) ({ entitiesType } = task)
    const params = {
      entitiesType,
      previousTasks: previousTasksIds
    }
    await getNextTask(params)
      .then(newTask => {
        if (!newTask) {
          reset()
          noTask = true
          app.navigate('/tasks/works')
          return
        }
        task = newTask
        app.navigate(`/tasks/${task._id}`)
      })
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
    return preq.get(app.API.entities.getByUris([ fromUri, toUri ]))
      .then(({ entities }) => {
        from = serializeEntity(entities[fromUri])
        to = serializeEntity(entities[toUri])
      })
      .catch(err => {
        error = err
      })
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
          {error}
          {matchedTitles}
        />
      {/if}
    </div>
    <div class="to-entity">
      <h2>To</h2>
      {#if to}
        <TaskEntity
          entity={to}
          {error}
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
      {error}
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
    h3{
      color: white;
    }
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
    padding-top: 0.3em;
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
