<script>
  import { API } from '#app/api/api'
  import preq from '#app/lib/preq'
  import DashboardSection from '#tasks/components/dashboard/dashboard_section.svelte'
  import { I18n } from '#user/lib/i18n'

  const waitForTasksCounts = getTasksCounts()

  let tasksCountByEntitiesType
  const orderedEntitiesTypes = [ 'human', 'work', 'edition', 'serie', 'publisher', 'collection' ]

  async function getTasksCounts () {
    ({ tasksCount: tasksCountByEntitiesType } = await preq.get(API.tasks.count))
  }

</script>
<div class="dashboard-wrapper">
  <h1>
    {I18n('tasks dashboard')}
  </h1>
  <div class="entities-type-sections">
    {#await waitForTasksCounts then}
      {#each orderedEntitiesTypes as entitiesType}
        <DashboardSection
          {entitiesType}
          tasksCount={tasksCountByEntitiesType[entitiesType] || 0}
        />
      {/each}
    {/await}
  </div>
</div>
<style lang="scss">
  @import "#general/scss/utils";
  .dashboard-wrapper{
    max-width: 40em;
    @include display-flex(column, center);
    margin: auto;
  }
  h1{
    font-size: 2em;
    padding: 0.5em;
    @include sans-serif;
  }
  .entities-type-sections{
    @include display-flex(row, center, center, wrap);
  }
</style>
