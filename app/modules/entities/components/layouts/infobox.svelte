<script lang="ts">
  import app from '#app/app'
  import { isNonEmptyArray, isEntityUri } from '#app/lib/boolean_tests'
  import WrapToggler from '#components/wrap_toggler.svelte'
  import EntityClaimsLinks from '#entities/components/layouts/entity_claims_links.svelte'
  import { infoboxShortlistPropertiesByType, infoboxPropertiesByType } from '#entities/components/lib/claims_helpers'
  import { omitClaims } from '#entities/components/lib/work_helpers'
  import { getEntitiesAttributesByUris, type SerializedEntitiesByUris } from '#entities/lib/entities'
  import Spinner from '#general/components/spinner.svelte'
  import type { Claims, ExtendedEntityType, PropertyUri } from '#server/types/entity'
  import { I18n } from '#user/lib/i18n'
  import ClaimInfobox from './claim_infobox.svelte'

  export let claims: Claims = {}
  export let omittedProperties: PropertyUri[] = []
  export let relatedEntities: SerializedEntitiesByUris = {}
  export let entityType: ExtendedEntityType
  export let shortlistOnly = null
  export let listDisplay = false

  let allowlistedProperties
  const infoboxPropertiesToDisplay = infoboxPropertiesByType[entityType]

  if (shortlistOnly) {
    allowlistedProperties = infoboxShortlistPropertiesByType[entityType] || infoboxPropertiesToDisplay
  } else {
    allowlistedProperties = infoboxPropertiesToDisplay
  }
  allowlistedProperties = allowlistedProperties || []

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
  const waitingForEntities = getMissingEntities()

  let infoboxHeight, showDetails, infobox
  const wrappedInfoboxHeight = 128
  $: infoboxHeight = infobox?.clientHeight
  $: wrappedSize = listDisplay && infoboxHeight && infoboxHeight > wrappedInfoboxHeight
  $: displayedClaims = omitClaims(claims, omittedProperties)
</script>
<div class="claims-infobox-wrapper">
  <div
    bind:this={infobox}
    class:wrapped-size={wrappedSize && !showDetails}
    class="claims-infobox"
  >
    {#each allowlistedProperties as prop}
      <ClaimInfobox
        values={displayedClaims[prop]}
        {prop}
        entitiesByUris={relatedEntities}
        {entityType}
      />
    {/each}
    {#if !shortlistOnly}
      <EntityClaimsLinks {claims} />
    {/if}
  </div>
  {#if isNonEmptyArray(allowlistedProperties)}
    {#await waitingForEntities}
      <Spinner />
    {/await}
  {/if}
  {#if wrappedSize}
    <WrapToggler
      bind:show={showDetails}
      moreText={I18n('more details')}
      lessText={I18n('less details')}
    />
  {/if}
</div>

<style lang="scss">
  @import "#general/scss/utils";
  .claims-infobox{
    flex: 3 0 0;
  }
  .wrapped-size{
    // in sync with wrappedInfoboxHeight variable
    block-size: 125px;
    overflow: hidden;
  }
</style>
