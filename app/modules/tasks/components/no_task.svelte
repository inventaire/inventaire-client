<script>
  import Link from '#app/lib/components/link.svelte'
  import { pluralize } from '#entities/lib/types/entities_types'
  import { getTasksCounts } from '#tasks/components/lib/tasks_helpers'
  import { I18n } from '#user/lib/i18n'

  const waitForTasksCounts = getTasksCounts()

  const orderedTypes = [ 'merge', 'deduplicate' ]
  const orderedEntitiesTypes = [ 'human', 'work', 'edition', 'serie', 'publisher', 'collection' ]

  function getNextEntitiesTypeUrl (tasksCountByTypeAndEntitiesType) {
    const firstEntitiesTypes = orderedTypes.map(type => {
      const tasksCountByEntitiesType = tasksCountByTypeAndEntitiesType[type]
      const pluralizedEntitiesType = pluralize(findFirstOrderedKey(tasksCountByEntitiesType))
      if (pluralizedEntitiesType) {
        return `/tasks/${type}/${pluralizedEntitiesType}`
      }
    })
    return firstEntitiesTypes[0]
  }

  function findFirstOrderedKey (tasksCountByEntitiesType) {
    if (!tasksCountByEntitiesType) return
    const keys = Object.keys(tasksCountByEntitiesType)
    return orderedEntitiesTypes.find(entitiesType => {
      return keys.includes(entitiesType)
    })
  }
</script>

<div id="no-task">
  <p class="grey">
    {I18n('no task available')}
  </p>
  <Link
    url="/tasks"
    text={I18n('see dashboard')}
    tinyButton={true}
  />
  {#await waitForTasksCounts then tasksCountByTypeAndEntitiesType}
    {@const nextTaskUrl = getNextEntitiesTypeUrl(tasksCountByTypeAndEntitiesType)}
    {#if nextTaskUrl}
      <Link
        url={nextTaskUrl}
        text={I18n('resolve next tasks')}
        tinyButton={true}
      />
    {/if}
  {/await}
</div>

<style lang="scss">
  @use "#general/scss/utils";
  #no-task{
    @include display-flex(column, center, center);
    padding: 3em;
    p{
      padding: 2em;
    }
    :global(.tiny-button){
      margin: 0.5em
    }
  }
</style>
