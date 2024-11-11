<script>
  import DashboardSection from '#tasks/components/dashboard/dashboard_section.svelte'
  import { getTasksCounts } from '#tasks/components/lib/tasks_helpers'
  import { I18n } from '#user/lib/i18n'

  const waitForTasksCounts = getTasksCounts()

  const mergeEntitiesTypes = [ 'human', 'work', 'edition', 'serie', 'publisher', 'collection' ]
  const deduplicateEntitiesTypes = [ 'human', 'work' ]
  app.navigate('/tasks')
</script>
<div class="dashboard-wrapper">
  <h1>
    {I18n('tasks dashboard')}
  </h1>
  {#await waitForTasksCounts then tasksCountByTypeAndEntitiesType}
    {#if tasksCountByTypeAndEntitiesType.merge}
      <h2>
        {I18n('user merge request')}
      </h2>
      <div class="sections">
        {#each mergeEntitiesTypes as entitiesType}
          <DashboardSection
            {entitiesType}
            tasksCount={tasksCountByTypeAndEntitiesType.merge[entitiesType] || 0}
            type="merge"
          />
        {/each}
      </div>
    {/if}
    {#if tasksCountByTypeAndEntitiesType.deduplicate}
      <h2>
        {I18n('deduplicate tasks')}
      </h2>
      <div class="sections">
        {#each deduplicateEntitiesTypes as entitiesType}
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
  @import "#general/scss/utils";
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
