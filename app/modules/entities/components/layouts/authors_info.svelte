<script>
  import { I18n } from '#user/lib/i18n'
  import Spinner from '#general/components/spinner.svelte'
  import { isNonEmptyArray, isNonEmptyPlainObject } from '#lib/boolean_tests'
  import { getEntitiesAttributesFromClaims } from '#entities/lib/entities'
  import AuthorDisplay from './author_display.svelte'

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
    const attributes = [ 'labels', 'claims', 'image' ]
    if (isNonEmptyPlainObject(authorsClaims)) {
      authorsByUris = await getEntitiesAttributesFromClaims(authorsClaims, attributes)
    }
  }
</script>
{#await waitingForAuthors}
  <Spinner/>
{:then}
  {#if authorsByUris}
    <div class="authors-info">
      {#each authorProperties as prop}
        {#if isNonEmptyArray(claims[prop])}
          <div class="{authorRoles[prop]} authors-role">
            <span class="label">{I18n(prop)}</span>
            <div class="authors">
              {#each claims[prop] as authorUri}
                <div class="author">
                  <AuthorDisplay
                    entityData={authorsByUris[authorUri]}
                  />
                </div>
              {/each}
            </div>
          </div>
        {/if}
      {/each}
    </div>
  {/if}
{/await}

<style lang="scss">
  @import '#general/scss/utils';
  .authors-info{
    @include display-flex(row, flex-end, flex-start, wrap);
  }
  .authors-role{
    @include display-flex(column, flex-start, flex-start, wrap);
  }
  .authors{
    @include display-flex(row, flex-end, flex-start, wrap);
  }
  .author{
    margin-right: 0.5em;
  }
  .label{
    color: $grey;
    font-size: 0.9rem;
    margin-bottom: 0.1em;
  }
</style>
