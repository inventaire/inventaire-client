<script>
  import { I18n } from '#user/lib/i18n'
  import ImportersSection from '#inventory/components/importer/importers_section.svelte'
  import SelectButtonGroup from '#inventory/components/select_button_group.svelte'
  import SelectShelves from '#inventory/components/importer/select_shelves.svelte'
  import CandidatesSection from '#inventory/components/importer/candidates_section.svelte'
  import ImportItemsSection from '#inventory/components/importer/import_items_section.svelte'
  import Counter from '#components/counter.svelte'

  let processedPreCandidatesCount
  let totalPreCandidates, showCanditates, showImportItems
  let candidates = []
  let transaction, listing
  let shelvesIds = []
  $: {
    showCanditates = (candidates.length > 0) && (processedPreCandidatesCount !== 0) && (processedPreCandidatesCount <= totalPreCandidates)
  }
  $: {
    showImportItems = (processedPreCandidatesCount !== 0) && (processedPreCandidatesCount === totalPreCandidates)
  }
</script>
<div id='importLayout'>
  <ImportersSection bind:candidates bind:processedPreCandidatesCount bind:totalPreCandidates/>
  <Counter count={processedPreCandidatesCount} total={totalPreCandidates}/>
  {#if showCanditates}
    <div id="candidatesElement">
      <CandidatesSection bind:candidates {processedPreCandidatesCount} {totalPreCandidates}/>
    </div>
    <h3>3/ {I18n('select the settings to apply to the selected books')}</h3>
    <SelectButtonGroup type="transaction" bind:selected={transaction}/>
    <SelectButtonGroup type="listing" bind:selected={listing}/>
    <SelectShelves bind:shelvesIds/>
  {/if}
  {#if showImportItems}
    <ImportItemsSection bind:candidates {transaction} {listing} {shelvesIds}/>
  {/if}
</div>

<style lang="scss">
  @import '#general/scss/utils';
  #importLayout{
    margin: 0 auto;
    max-width: 50em;
    /*Small screens*/
    @media screen and (max-width: $small-screen) {
      margin: 0 0.5em;
    }
  }
  h3{
    margin-top: 1em;
    text-align: center;
    padding-left: 0.2em;
    font-weight: bold;
  }
</style>
