<script lang="ts">
  import CandidatesSection from '#inventory/components/importer/candidates_section.svelte'
  import ExternalShelves from '#inventory/components/importer/external_shelves.svelte'
  import ImportItemsSection from '#inventory/components/importer/import_items_section.svelte'
  import ImportersSection from '#inventory/components/importer/importers_section.svelte'
  import ShelvesSelector from '#inventory/components/shelves_selector.svelte'
  import TransactionSelector from '#inventory/components/transaction_selector.svelte'
  import VisibilitySelector from '#inventory/components/visibility_selector.svelte'
  import { I18n } from '#user/lib/i18n'

  // Known cases: incoming from scan
  export let isbns

  // This importer is capable of creating items from:
  //   - import file from some other websites
  //   - isbns textfile
  //   - a text input
  // Step 1: process externalEntries (validate isbns, serialize data from files)
  // Step 2: create a candidates array of objects from externalEntries (find entities on the server when existing, propose to modify data if no entities found)
  // Step 3: send request for items creation from candidates (display errors if fails, display created items)

  // Some specifications to have in mind:
  // - An externalEntry may have data from file import (authors strings, a title string, publication date, pages etc.)
  // - An externalEntry may have an isbn (if so, some isbn data are derived from the isbn thanks to the isbn lib)
  // - A candidate may have associated entities (authors, a work and/or an edition, that are found from the server via the resolver and/or dataseeds)
  // - If a candidate have authors and work title strings but no associated data, the user may edit those strings

  let processing
  let candidates = []
  let transaction, visibility
  let shelvesIds = []
  let externalShelves = []
</script>
<div id="importLayout">
  <ImportersSection bind:candidates {processing} {isbns} />
  {#if candidates.length > 0}
    <CandidatesSection bind:candidates {processing} />
    <h3>3/ {I18n('select the settings to apply to the selected books')}</h3>
    <div class="panel">
      <TransactionSelector bind:transaction showDescription={true} />
      <VisibilitySelector bind:visibility showDescription={true} showTip={true} />
      <ShelvesSelector bind:shelvesIds showDescription={true} />
      <ExternalShelves bind:externalShelves {candidates} />
    </div>
  {/if}
  {#if !processing}
    <ImportItemsSection
      bind:candidates
      {transaction}
      {visibility}
      {shelvesIds}
      {externalShelves} />
  {/if}
</div>

<style lang="scss">
  @import "#general/scss/utils";
  #importLayout{
    margin: 0 auto;
    max-width: 50em;
    /* Small screens */
    @media screen and (max-width: $small-screen){
      margin: 0 0.5em;
    }
  }
  h3{
    margin-block-start: 1em;
    text-align: center;
    padding-inline-start: 0.2em;
    font-weight: bold;
  }
  .panel{
    @include panel;
    // - `fieldset + fieldset`: do not target apply to the first fieldset
    // - `:not(:empty)`: skip ShelvesSelector when empty
    :global(fieldset + fieldset:not(:empty)){
      margin-block-start: 1em;
    }
  }
</style>
