<script>
  import { clone, pluck } from 'underscore'
  import app from '#app/app'
  import preq from '#lib/preq'
  import { onChange } from '#lib/svelte/svelte'
  import { serializeEntity } from '#entities/lib/entities'
  import TaskControls from './task_controls.svelte'
  import TaskEntity from './task_entity.svelte'
  import getNextTask from '#tasks/lib/get_next_task.js'
  import { I18n } from '#user/lib/i18n'
  import { icon } from '#lib/icons'

  export let taskId, entitiesType

  let task, from, to, flash, matchedTitles, noTask, areBothInvEntities
  $: fromUri = task?.suspectUri
  $: toUri = task?.suggestionUri

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
      .catch(err => {
        flash = err
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
      lastTask: task,
      previousTasksIds
    }
    const newTask = await getNextTask(params)
    if (!newTask) {
      reset()
      noTask = true
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
    const { entities, redirects } = await preq.get(app.API.entities.getByUris([ fromUri, toUri ]))
      .catch(err => {
        flash = err
      })
    if (areRedirects(entities, redirects)) {
      await updateTask(task._id, 'state', 'merged')
      return next()
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
    return preq.put(app.API.tasks.update, params)
  }

  function areRedirects (entities, redirects) {
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
      {#key from}
        <TaskEntity
          entity={from}
          {flash}
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
          {flash}
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
    min-height: 100vh;
    flex: 1 0 0;
  }
  .to-entity{
    min-height: 100vh;
    background-color: $light-grey;
    padding-left: 1em;
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
  .swap{
    position: relative;
    left: 1.3em;
    top: 30vh;
    background-color: white;
    padding: 0.5em;
    border-radius: 50%;
  }
</style>
