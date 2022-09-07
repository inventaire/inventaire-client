<script>
  import { I18n } from '#user/lib/i18n'
  import { onChange } from '#lib/svelte/svelte'
  import ExternalShelf from '#inventory/components/importer/external_shelf.svelte'

  export let candidates
  export let externalShelves

  const groupExternalShelves = () => {
    const lastCandidate = candidates[candidates.length - 1]
    const { index, shelvesNames } = lastCandidate
    if (shelvesNames) shelvesNames.forEach(assignOrCreateExternalShelves(index))
  }

  const assignOrCreateExternalShelves = candidateIndex => candidateShelfName => {
    const existingShelf = externalShelves.find(({ name }) => name === candidateShelfName)
    if (existingShelf) {
      existingShelf.candidatesIndexes = [ ...existingShelf.candidatesIndexes, candidateIndex ]
    } else {
      const newShelf = {
        name: candidateShelfName,
        candidatesIndexes: [ candidateIndex ],
        checked: true,
      }
      externalShelves = [ ...externalShelves, newShelf ]
    }
  }

  $: onChange(candidates, groupExternalShelves)
</script>
<fieldset class="import-shelves">
  <legend>
    <p class="title">{I18n('external_shelves_importer')}</p>
    <p class="description">{I18n('external_shelves_importer_description')}</p>
  </legend>
  {#each externalShelves as externalShelf}
    <ExternalShelf {externalShelf}/>
  {/each}
</fieldset>
<style lang="scss">
  @import '#general/scss/utils';
  .description{
    font-size: 0.9rem;
    margin-bottom: 0.5em;
  }
  .import-shelves{
    margin: 1em 0
  }
</style>
