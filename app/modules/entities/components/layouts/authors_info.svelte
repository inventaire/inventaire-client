<script>
  import { pick } from 'underscore'
  import Spinner from '#general/components/spinner.svelte'
  import { isNonEmptyPlainObject } from '#lib/boolean_tests'
  import { getEntitiesAttributesFromClaims } from '#entities/lib/entities'
  import AuthorsInfoRole from './authors_info_role.svelte'
  import { propertiesByRoles } from '#entities/components/lib/claims_helpers'

  export let claims = {}

  let authorsByUris
  let authorsProperties = Object.values(propertiesByRoles).flat()
  let authorsClaims = pick(claims, authorsProperties)

  const waitingForAuthors = getAuthors()
  async function getAuthors () {
    if (isNonEmptyPlainObject(authorsClaims)) {
      // Claims attribute is necessary to get birth and death years
      const attributes = [ 'labels', 'claims', 'image' ]
      authorsByUris = await getEntitiesAttributesFromClaims(authorsClaims, attributes)
    }
  }
</script>

{#await waitingForAuthors}
  <Spinner />
{:then}
  {#if authorsByUris}
    <div class="authors-info">
      {#each Object.keys(propertiesByRoles) as roleLabel}
        <AuthorsInfoRole
          {roleLabel}
          roleProperties={propertiesByRoles[roleLabel]}
          {claims}
          {authorsByUris}
        />
      {/each}
    </div>
  {/if}
{/await}

<style lang="scss">
  @import "#general/scss/utils";
  .authors-info{
    @include display-flex(row, flex-end, flex-start, wrap);
  }
</style>
