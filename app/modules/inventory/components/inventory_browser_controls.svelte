<script>
  import { I18n } from '#user/lib/i18n'
  import SelectDropdown from '#components/select_dropdown.svelte'
  import InventoryBrowserFacet from '#inventory/components/inventory_browser_facet.svelte'
  import Spinner from '#components/spinner.svelte'

  export let waitForInventoryData, displayMode, facetsSelectors, facetsSelectedValues, intersectionWorkUris

  const displayOptions = [
    { value: 'cascade', icon: 'th-large', text: I18n('cascade') },
    { value: 'list', icon: 'align-justify', text: I18n('list') },
  ]
</script>

<div class="controls" class:ready={facetsSelectors != null}>
  <div class="filters">
    <span class="control-label">{I18n('filters')}</span>
    {#await waitForInventoryData}
      <Spinner center={true} />
    {:then}
      <div class="selectors">
        {#each Object.keys(facetsSelectors) as sectionName}
          <InventoryBrowserFacet
            bind:facetsSelectors
            bind:facetsSelectedValues
            {sectionName}
            {intersectionWorkUris}
          />
        {/each}
      </div>
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
  .selectors{
    @include display-flex(row, center, center, wrap);
  }

  /*Small screens*/
  @media screen and (max-width: $smaller-screen) {
    .controls{
      flex-direction: column;
    }
    .filters{
      flex-direction: column;
    }
    .selectors{
      flex-direction: column;
    }
    .display-controls{
      margin: 1em;
    }
  }
</style>
