<script lang="ts">
  import { pick } from 'underscore'
  import { isNonEmptyPlainObject } from '#app/lib/boolean_tests'
  import { onChange } from '#app/lib/svelte/svelte'
  import { propertiesByRoles } from '#entities/components/lib/claims_helpers'
  import { getEntitiesAttributesFromClaims } from '#entities/lib/entities'
  import Spinner from '#general/components/spinner.svelte'
  import AuthorsInfoRole from './authors_info_role.svelte'

  export let claims = {}

  let authorsByUris
  const authorsProperties = Object.values(propertiesByRoles).flat()
  $: authorsClaims = pick(claims, authorsProperties)
  const waitingForAuthors = getAuthors()
  async function getAuthors () {
    if (isNonEmptyPlainObject(authorsClaims)) {
      // 'claims' attribute is necessary to get birth and death years
      const attributes = [ 'labels', 'claims', 'image' ] as const
      authorsByUris = await getEntitiesAttributesFromClaims(authorsClaims, attributes)
    }
  }

  $: onChange(authorsClaims, getAuthors)
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
