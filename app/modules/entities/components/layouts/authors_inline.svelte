<script lang="ts">
  import app from '#app/app'
  import { isNonEmptyArray } from '#app/lib/boolean_tests'
  import { getEntitiesAttributesByUris } from '#entities/lib/entities'
  import { getBestLangValue } from '#entities/lib/get_best_lang_value'
  import Spinner from '#general/components/spinner.svelte'

  export let entitiesUris = []

  let entitiesByUris
  const firstAuthorsLimit = 5
  const firstAuthorsUris = entitiesUris.slice(0, firstAuthorsLimit)

  const waitingForAuthors = getAuthors()
  async function getAuthors () {
    if (isNonEmptyArray(entitiesUris)) {
      const attributes = [ 'labels' ] as const
      ;({ entities: entitiesByUris } = await getEntitiesAttributesByUris({ uris: entitiesUris, attributes }))
    }
  }

  function getBestLabel (claimValue) {
    return getBestLangValue(app.user.lang, null, entitiesByUris[claimValue].labels).value
  }

</script>

{#await waitingForAuthors}
  <Spinner />
{:then}
  {#if entitiesByUris && isNonEmptyArray(entitiesUris)}
    <p class="authors-labels">
      {firstAuthorsUris.map(getBestLabel).join(', ')}
      {#if firstAuthorsLimit < entitiesUris.length}
        ...
      {/if}
    </p>
  {/if}
{/await}

<style lang="scss">
  @import "#general/scss/utils";
  .authors-labels{
    color: $grey;
    font-size: 0.9rem;
    margin-block-end: 0.1em;
  }
</style>
