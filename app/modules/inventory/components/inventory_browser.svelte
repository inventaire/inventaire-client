<script>
  import { I18n } from '#user/lib/i18n'
  import SelectDropdown from '#components/select_dropdown.svelte'
  import InventoryBrowserFacets from '#inventory/components/inventory_browser_facets.svelte'
  import { getSelectorsData } from '#inventory/components/lib/inventory_browser_helpers'
  import Spinner from '#components/spinner.svelte'

  export let itemsDataPromise

  let worksTree, workUriItemsMap, itemsByDate
  const waitForInventoryData = itemsDataPromise
    .then(res => {
      ;({ worksTree, workUriItemsMap, itemsByDate } = res)
    })
    .then(() => showEntitySelectors())

  let facetsSelectors, facetsSelectedValues
  async function showEntitySelectors () {
    ;({ facetsSelectors, facetsSelectedValues } = await getSelectorsData({ worksTree }))
  }

  const displayOptions = [
    { value: 'cascade', icon: 'th-large', text: I18n('cascade') },
    { value: 'list', icon: 'align-justify', text: I18n('list') },
  ]

  // TODO: persist display mode in localstorage
  let displayMode = 'cascade'
</script>

<div class="controls" class:ready={facetsSelectors != null}>
  <div class="filters">
    <span class="control-label">{I18n('filters')}</span>
    {#await waitForInventoryData}
      <Spinner center={true} />
    {:then}
      <InventoryBrowserFacets
        bind:facetsSelectors
        bind:facetsSelectedValues
      />
    {/await}
  </div>
  <div class="display-controls">
    <SelectDropdown bind:value={displayMode} options={displayOptions} buttonLabel={I18n('display_mode')}/>
  </div>
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .controls, .filters{
    @include display-flex(row, center, center, wrap);
    @include radius;
    /*Small screens*/
    @media screen and (max-width: $smaller-screen) {
      padding: 0.3em 0 0.2em 0;
    }
    /*Large screens*/
    @media screen and (min-width: $smaller-screen) {
      padding: 0.2em 0.5em;
    }
  }
  .controls{
    background-color: $inventory-nav-grey;
    @include transition(opacity);
    opacity: 1;
    margin: 0.5em 0 0.5em 0;
    &:not(.ready){
      .filters{
        flex: 1 0 0;
      }
    }
  }
  .display-controls{
    /*Large screens*/
    @media screen and (min-width: $smaller-screen) {
      margin-left: auto;
    }
  }
  .control-label{
    color: $grey;
    /*Large screens*/
    @media screen and (min-width: $smaller-screen) {
      margin: 1em 0.5em;
    }
  }

  /*Small screens*/
  @media screen and (max-width: $smaller-screen) {
    .controls{
      flex-direction: column;
    }
    .filters{
      flex-direction: column;
    }
    .display-controls{
      margin: 1em;
    }
  }
</style>
