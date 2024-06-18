<script lang="ts">
  import { isNonEmptyArray } from '#app/lib/boolean_tests'
  import { getEntitiesAttributesFromClaims } from '#entities/lib/entities'
  import getBestLangValue from '#entities/lib/get_best_lang_value'
  import Spinner from '#general/components/spinner.svelte'

  export let entitiesUris = []

  let authorsByUris
  const firstAuthorsLimit = 5
  const firstAuthorsUris = entitiesUris.slice(0, firstAuthorsLimit)

  const waitingForAuthors = getAuthors()
  async function getAuthors () {
    if (isNonEmptyArray(entitiesUris)) {
      const attributes = [ 'labels' ] as const
      authorsByUris = await getEntitiesAttributesFromClaims(entitiesUris, attributes)
    }
  }

  function getBestLabel (claimValue) {
    return getBestLangValue(app.user.lang, null, authorsByUris[claimValue].labels).value
  }

</script>

{#await waitingForAuthors}
  <Spinner />
{:then}
  {#if authorsByUris && isNonEmptyArray(entitiesUris)}
    <p class="authors-labels">
      {#each firstAuthorsUris as claimValue, i}
        <!-- This peculiar formatting is used to avoid undesired spaces to be inserted
        See https://github.com/sveltejs/svelte/issues/3080 -->
        {getBestLabel(claimValue)}{#if i !== firstAuthorsUris.length - 1}
          ,&nbsp;
        {/if}
      {/each}
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
