<script>
  import { I18n } from '#user/lib/i18n'
  import Spinner from '#general/components/spinner.svelte'
  import { isNonEmptyArray } from '#lib/boolean_tests'
  import { getItemsData } from './items_lists/items_lists'
  import ItemsByCategories from './items_lists/items_by_categories.svelte'

  export let uri

  let items = []
  let initialItems = []

  const getItemsByCategories = async () => {
    let uris
    if (uri) uris = [ uri ]
    initialItems = await getItemsData(uris)
    items = initialItems
  }

  $: emptyList = !isNonEmptyArray(items)
  $: notAllDocsAreDisplayed = items.length !== initialItems.length
</script>
{#await getItemsByCategories()}
  <div class="loading-wrapper">
    <p class="loading">{I18n('fetching available books...')} <Spinner/></p>
  </div>
{:then}
  <ItemsByCategories
    {initialItems}
  />
{/await}

<style lang="scss">
  @import '#general/scss/utils';
  @import '#entities/scss/items_lists';
</style>
