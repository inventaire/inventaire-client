<script>
  import { i18n } from '#user/lib/i18n'
  import Spinner from '#general/components/spinner.svelte'
  import { isNonEmptyArray, isNonEmptyPlainObject } from '#lib/boolean_tests'
  import { getEntitiesAttributesFromClaims } from '#entities/lib/entities'
  import AuthorDisplay from './author_display.svelte'
  import { propertiesByRoles } from '#entities/components/lib/claims_helpers'

  export let claims = {}

  let authorsByUris

  const authorProperties = Object.values(propertiesByRoles).flat()

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

  const claimsProperties = Object.keys(claims)
  const hasPropertiesToDisplay = role => isNonEmptyArray(_.intersection(propertiesByRoles[role], claimsProperties))
</script>

{#await waitingForAuthors}
  <Spinner />
{:then}
  {#if authorsByUris}
    <div class="authors-info">
      {#each Object.keys(propertiesByRoles) as role}
        {#if hasPropertiesToDisplay(role)}
          <div class="{role} authors-role">
            <span class="label">{i18n(role)}</span>
            <div class="authors">
              {#each propertiesByRoles[role] as prop}
                {#if claims[prop]}
                  {#each claims[prop] as claimValue}
                    <div class="author">
                      <AuthorDisplay
                        entityData={authorsByUris[claimValue]}
                        {claimValue}
                      />
                    </div>
                  {/each}
                {/if}
              {/each}
            </div>
          </div>
        {/if}
      {/each}
    </div>
  {/if}
{/await}

<style lang="scss">
  @import "#general/scss/utils";
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
    margin-inline-end: 0.5em;
  }
  .label{
    color: $grey;
    font-size: 0.9rem;
    margin-block-end: 0.1em;
  }
</style>
