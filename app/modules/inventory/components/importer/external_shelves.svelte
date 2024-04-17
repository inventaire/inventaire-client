<script lang="ts">
  import { debounce } from 'underscore'
  import { onChange } from '#app/lib/svelte/svelte'
  import ExternalShelf from '#inventory/components/importer/external_shelf.svelte'
  import { i18n } from '#user/lib/i18n'

  export let candidates
  export let externalShelves

  const refreshExternalShelves = () => {
    const externalShelvesByName = {}
    candidates.forEach(candidate => {
      const { index: candidateIndex, shelvesNames } = candidate
      if (shelvesNames) {
        shelvesNames.forEach(shelfName => {
          externalShelvesByName[shelfName] = externalShelvesByName[shelfName] || newShelf(shelfName)
          externalShelvesByName[shelfName].candidatesIndexes.push(candidateIndex)
        })
      }
    })
    externalShelves = Object.values(externalShelvesByName)
  }

  const newShelf = name => ({ name, candidatesIndexes: [], checked: true })

  const lazyRefreshExternalShelves = debounce(refreshExternalShelves, 500)

  $: onChange(candidates, lazyRefreshExternalShelves)
</script>

{#if externalShelves.length > 0}
  <fieldset class="import-shelves">
    <legend>
      <p class="title">{i18n('external_shelves_importer')}</p>
      <p class="description">{i18n('external_shelves_importer_description')}</p>
    </legend>
    {#each externalShelves as externalShelf}
      <ExternalShelf {externalShelf} />
    {/each}
  </fieldset>
{/if}

<style lang="scss">
  @import "#general/scss/utils";
  .description{
    font-size: 0.9rem;
    margin-block-end: 0.5em;
  }
  .import-shelves{
    margin: 1em 0;
  }
</style>
