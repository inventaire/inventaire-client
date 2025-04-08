<script>
  import DashboardSection from '#tasks/components/dashboard/dashboard_section.svelte'
  import { getTasksCounts, entitiesTypesByTypes } from '#tasks/components/lib/tasks_helpers'
  import { i18n, I18n } from '#user/lib/i18n'

  const waitForTasksCounts = getTasksCounts()
  app.navigate('/tasks')
</script>
<div class="dashboard-wrapper">
  <h1>
    {I18n('tasks dashboard')}
  </h1>
  {#await waitForTasksCounts then tasksCountByTypeAndEntitiesType}
    {#if tasksCountByTypeAndEntitiesType.merge}
      <h2>
        {i18n('Merge requests')}
      </h2>
      <div class="sections">
        {#each entitiesTypesByTypes.merge as entitiesType}
          <DashboardSection
            {entitiesType}
            tasksCount={tasksCountByTypeAndEntitiesType.merge[entitiesType] || 0}
            type="merge"
          />
        {/each}
      </div>
    {/if}
    {#if tasksCountByTypeAndEntitiesType.delete}
      <h2>
        {i18n('Delete requests')}
      </h2>
      <div class="sections">
        {#each entitiesTypesByTypes.delete as entitiesType}
          <DashboardSection
            {entitiesType}
            tasksCount={tasksCountByTypeAndEntitiesType.delete[entitiesType] || 0}
            type="delete"
          />
        {/each}
      </div>
    {/if}
    {#if tasksCountByTypeAndEntitiesType.deduplicate}
      <h2>
        {i18n('Deduplication tasks')}
      </h2>
      <div class="sections">
        {#each entitiesTypesByTypes.deduplicate as entitiesType}
          <DashboardSection
            {entitiesType}
            type="deduplicate"
            tasksCount={tasksCountByTypeAndEntitiesType.deduplicate[entitiesType] || 0}
          />
        {/each}
      </div>
    {/if}
  {/await}
</div>
<style lang="scss">
  @use "#general/scss/utils";
  .dashboard-wrapper{
    max-width: 40em;
    @include display-flex(column, center);
    margin: auto;
  }
  h1, h2{
    padding: 0.5em;
    @include sans-serif;
  }
  h1{
    font-size: 2em;
  }
  h2{
    padding-block-start: 1em;
    font-size: 1.5em;
  }
  .sections{
    @include display-flex(row, center, center, wrap);
  }
</style>
