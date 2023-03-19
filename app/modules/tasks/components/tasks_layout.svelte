<script>
  import app from '#app/app'
  import preq from '#lib/preq'
  import { onChange } from '#lib/svelte/svelte'
  import TaskControls from './task_controls.svelte'

  export let taskId

  let task, from, to, error

  const waitForTask = getTask()

  async function getTask () {
    return getTaskById(taskId)
      .catch(err => {
        error = err
      })
  }

  async function getTaskById (id) {
    const { tasks } = await preq.get(app.API.tasks.byIds(id))
    task = tasks[0]
  }

  function next () {
  // getNextTask()
  }

  async function updateFromAndToEntities () {
    error = null
    if (!task) return
    const fromUri = task.suspectUri
    const toUri = task.suggestionUri
    const { entities } = await preq.get(app.API.entities.getByUris([ fromUri, toUri ]))
      .catch(err => {
        error = err
      })
    from = entities[fromUri]
    to = entities[toUri]
  }

  $: onChange(task, updateFromAndToEntities)
</script>
{#await waitForTask then}
  <TaskControls
    {task}
    {from}
    {to}
    {error}
    on:next={next}
  />
{/await}

<style lang="scss">
  @import "#general/scss/utils";
</style>
