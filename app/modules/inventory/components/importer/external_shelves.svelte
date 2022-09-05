<script>
  import { I18n } from '#user/lib/i18n'
  import { onChange } from '#lib/svelte/svelte'
  import ExternalShelf from '#inventory/components/importer/external_shelf.svelte'

  export let candidates
  export let externalShelves

  const groupExternalShelves = () => {
    const lastCandidate = candidates[candidates.length - 1]
    const { index, shelves } = lastCandidate
    if (shelves) shelves.forEach(assignOrCreateExternalShelves(index))
  }

  const assignOrCreateExternalShelves = candidateIndex => candidateShelf => {
    const existingShelf = externalShelves.find(importShelf => importShelf.name === candidateShelf)
    if (existingShelf) {
      existingShelf.candidatesIndexes = [ ...existingShelf.candidatesIndexes, candidateIndex ]
    } else {
      const newShelf = {
        name: candidateShelf,
        candidatesIndexes: [ candidateIndex ],
        checked: true,
      }
      externalShelves = [ ...externalShelves, newShelf ]
    }
  }

  $: onChange(candidates, groupExternalShelves)
</script>
<div class="importShelves">
  <label for="external-shelves-selector">
    <p class="title">{I18n('external_shelves_importer')}</p>
    <p class="description">{I18n('external_shelves_importer_description')}</p>
  </label>
  <div id="external-shelves-selector" class="select-button-group" role="menu">
    {#each externalShelves as externalShelf}
      <ExternalShelf {externalShelf}/>
    {/each}
  </div>
</div>
<style lang="scss">
  @import '#general/scss/utils';
  .description{
    font-size: 0.9rem;
    margin-bottom: 0.5em;
  }
  .importShelves{
    margin: 1em 0
  }
</style>
