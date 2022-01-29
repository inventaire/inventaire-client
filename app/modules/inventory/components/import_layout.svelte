<script>
  import { I18n } from '#user/lib/i18n'
  import ImportersSection from '#inventory/components/importer/importers_section.svelte'
  import SelectButtonGroup from '#inventory/components/select_button_group.svelte'
  import SelectShelves from '#inventory/components/importer/select_shelves.svelte'
  import CandidatesSection from '#inventory/components/importer/candidates_section.svelte'
  import ImportItemsSection from '#inventory/components/importer/import_items_section.svelte'

  let processedPreCandidates, totalPreCandidates
  let candidates = []
  let transaction, listing
  let shelvesIds = []
</script>
<div id='importLayout'>
  <ImportersSection bind:candidates bind:processedPreCandidates bind:totalPreCandidates/>
  <div hidden="{!candidates.length > 0}">
    <div id="candidatesElement">
      <CandidatesSection bind:candidates {processedPreCandidates} {totalPreCandidates}/>
    </div>
    <h3>3/ {I18n('select the settings to apply to the selected books')}</h3>
    <div class="itemsSettings">
      <SelectButtonGroup type="transaction" bind:selected={transaction}/>
      <SelectButtonGroup type="listing" bind:selected={listing}/>
      <SelectShelves bind:shelvesIds/>
    </div>
  </div>
  <ImportItemsSection bind:candidates {transaction} {listing} {shelvesIds}/>
</div>

<style lang="scss">
  @import 'app/modules/general/scss/utils';
  #importLayout{
    margin: 0 auto;
    max-width: 70em;
  }
  h3{
    margin-top: 1em;
    text-align: center;
  }
</style>
