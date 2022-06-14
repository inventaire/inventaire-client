<script>
  import Spinner from '#general/components/spinner.svelte'
  import { isNonEmptyArray } from '#lib/boolean_tests'
  import { I18n } from '#user/lib/i18n'
  import ItemsByCategories from './items_lists/items_by_categories.svelte'
  import { getItemsData } from './items_lists/items_lists'

  export let editionsUris, initialItems = [], usersSize

  let items = []
  let loading

  let fetchedEditionsUris = []
  const getItemsByCategories = async () => {
    // easy caching, waiting for proper svelte caching tool
    if (_.isEqual(fetchedEditionsUris, editionsUris)) return
    fetchedEditionsUris = editionsUris
    loading = true
    initialItems = await getItemsData(editionsUris)
    loading = false
    items = initialItems
  }

  $: emptyList = !isNonEmptyArray(items)
  $: usersSize = _.compact(_.uniq(items.map(_.property('owner')))).length
  $: editionsUris && getItemsByCategories()
  $: displayCover = editionsUris?.length > 1
</script>

{#if loading}
  <div class="loading-wrapper">
    <p class="loading">{I18n('fetching available books...')} <Spinner/></p>
  </div>
{:else}
  {#if !emptyList}
    <div class="loading-wrapper">
      <h6 class="items-title">
        {I18n('users with these editions')}
      </h6>
    </div>
    <ItemsByCategories
      {initialItems}
      {displayCover}
    />
  {/if}
{/if}

<style lang="scss">
  @import '#general/scss/utils';
  .loading-wrapper{
    display: none;
  }

  /*Small screens*/
  @media screen and (max-width: $small-screen) {
    .loading-wrapper{
      @include display-flex(column, center);
    }
  }
</style>
