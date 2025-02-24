<script lang="ts">
  import app from '#app/app'
  import { isEntityUri, isNonEmptyArray } from '#app/lib/boolean_tests'
  import { getEntitiesAttributesByUris, type SerializedEntitiesByUris } from '#entities/lib/entities'
  import type { ExtendedEntityType, PropertyUri, SimplifiedClaims } from '#server/types/entity'
  import ClaimInfobox from './claim_infobox.svelte'

  export let allowlistedProperties: PropertyUri[]
  export let claims: SimplifiedClaims = {}
  export let relatedEntities: SerializedEntitiesByUris = {}
  export let entityType: ExtendedEntityType
  export let waitingForEntities = null

  async function getMissingEntities () {
    const missingUris = []
    allowlistedProperties.forEach(prop => {
      if (claims[prop]) {
        const propMissingUris = claims[prop].filter(value => {
          if (isEntityUri(value)) return !relatedEntities[value]
          else return false
        })
        missingUris.push(...propMissingUris)
      }
    })
    if (isNonEmptyArray(missingUris)) {
      const { entities } = await getEntitiesAttributesByUris({
        uris: missingUris,
        attributes: [ 'info', 'labels' ],
        lang: app.user.lang,
      })
      relatedEntities = { ...relatedEntities, ...entities }
    }
  }
  waitingForEntities = getMissingEntities()
</script>

{#each allowlistedProperties as prop (prop)}
  {#if isNonEmptyArray(claims[prop])}
    <ClaimInfobox
      values={claims[prop]}
      {prop}
      entitiesByUris={relatedEntities}
      {entityType}
    />
  {/if}
{/each}
