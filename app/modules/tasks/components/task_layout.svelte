<script lang="ts">
  import { API } from '#app/api/api'
  import app from '#app/app'
  import Flash from '#app/lib/components/flash.svelte'
  import preq from '#app/lib/preq'
  import type { TaskId } from '#server/types/task'
  import { getTaskMetadata } from '#tasks/components/lib/tasks_helpers'
  import { getNextTask } from '#tasks/lib/get_next_task'
  import DeleteLayout from './delete_layout.svelte'
  import MergeLayout from './merge_layout.svelte'
  import NoTask from './no_task.svelte'
  import TaskBreadcrumb from './task_breadcrumb.svelte'

  export let taskId: TaskId
  export let entitiesType, type

  let task, flash

  let nextTaskOffset = 0
  const waitForTask = getTask()

  async function getTask () {
    const promise = taskId ? taskById() : showNextTask()
    return promise
      .catch(err => {
        flash = err
      })
  }

  async function taskById () {
    const { tasks } = await preq.get(API.tasks.byIds(taskId))
    task = tasks[0];
    ({ type, entitiesType } = task)
    app.navigate(`/tasks/${task._id}`, getTaskMetadata(task))
  }

  async function showNextTask () {
    if (!entitiesType) ({ entitiesType } = task)
    if (!task) (nextTaskOffset = 0)
    const newTask = await getNextTask({ type, entitiesType, offset: nextTaskOffset })

    if (!newTask) {
      return resetTaskLayout()
    }
    task = newTask
    nextTaskOffset++
    app.navigate(`/tasks/${task._id}`, getTaskMetadata(task))
  }

  function resetTaskLayout () {
    app.navigate('/tasks/none', getTaskMetadata())
    nextTaskOffset = 0
    task = null
  }
  $: taskId = task?._id
</script>
<TaskBreadcrumb
  {entitiesType}
  {type}
  {taskId}
/>
{#await waitForTask then}
  {#if task}
    {#if type === 'delete'}
      <DeleteLayout
        {task}
        on:next={showNextTask}
      />
    {:else}
      <MergeLayout
        {task}
        on:next={showNextTask}
      />
    {/if}
  {:else}
    <NoTask />
  {/if}
  <Flash bind:state={flash} />
{/await}
