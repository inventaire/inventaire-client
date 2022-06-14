<script>
  import { isNonEmptyArray, isNonEmptyPlainObject } from '#lib/boolean_tests'
  import { getEntitiesAttributesFromClaims } from '#entities/lib/entities'
  import AuthorsDisplay from './authors_display.svelte'
  import Spinner from '#general/components/spinner.svelte'

  export let claims = {}

  let authorsByUris

  const authorRoles = {
    'wdt:P50': 'author',
    'wdt:P58': 'scenarist',
    'wdt:P110': 'illustrator',
    'wdt:P6338': 'colorist'
  }

  const authorProperties = Object.keys(authorRoles)

  // getting authors entities independantly from infobox claims to fetch claims attributes and display birth/death years
  const waitingForAuthors = getAuthors()
  async function getAuthors () {
    let authorsClaims = _.pick(claims, authorProperties)
    // claims used for getting birth and death years
    const attributes = [ 'labels', 'claims' ]
    if (isNonEmptyPlainObject(authorsClaims)) {
      authorsByUris = await getEntitiesAttributesFromClaims(authorsClaims, attributes)
    }
  }
</script>
{#await waitingForAuthors}
  <Spinner/>
{:then}
  <div class="authors-info">
    {#each authorProperties as prop}
      {#if isNonEmptyArray(claims[prop])}
        <div class="authors">
          <AuthorsDisplay
            {prop}
            values={claims[prop]}
            authorsByUris={authorsByUris}
            authorRole={authorRoles[prop]}
          />
        </div>
      {/if}
    {/each}
  </div>
{/await}

<style lang="scss">
  @import '#general/scss/utils';
  .authors-info{
    @include display-flex(row, center, flex-start, wrap);
    :not(:last-child):after{
      margin-right: 0.3em;
      content: ',';
    }
  }
  .authors{
    @include display-flex(row, flex-end, flex-start, wrap);
  }
  /*Large screens*/
  @media screen and (min-width: 1200px) {
    .authors-info{
      // give space below edit data button when no cover
      margin-left: 0 0 0 1em;
    }
  }
</style>
