<script>
  import { I18n } from '#user/lib/i18n'
  import ImportersSection from '#inventory/components/importer/importers_section.svelte'
  import SelectButtonGroup from '#inventory/components/select_button_group.svelte'
  import SelectShelves from '#inventory/components/importer/select_shelves.svelte'
  import CandidatesSection from '#inventory/components/importer/candidates_section.svelte'
  import ImportItemsSection from '#inventory/components/importer/import_items_section.svelte'
  import Counter from '#components/counter.svelte'

  // incoming from scan
  export let isbns

  // This importer is capable of creating items from:
  //   - import file from some other websites
  //   - isbns textfile
  //   - a text input
  // Step 1: creating preCandidates (validate isbns, extract data from files)
  // Step 2: creating candidates from preCandidates (find entities on the server when existing, propose to modify data if no entities found)
  // Step 3: creating items from candidates (display errors if fails, display created items)

  // Some specifications to have in mind:
  // - A preCandidate may have data from file import (authors strings, work title strings, publication date, pages etc.)
  // - A preCandidate may have an isbn (if so some processed isbn data are derived from the isbn thanks to the isbn lib)
  // - A candidate may have associated entities (authors, a work and/or an edition)
  // - If a candidate have authors and work title strings but no associated data, the user may edit those strings
  // - Items are created from checked candidates

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
  <ImportersSection bind:candidates bind:processedPreCandidatesCount bind:totalPreCandidates {isbns}/>
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
