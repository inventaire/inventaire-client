<script lang="ts">
  import { isNonEmptyArray } from '#app/lib/boolean_tests'
  import WrapToggler from '#components/wrap_toggler.svelte'
  import ClaimsInfobox from '#entities/components/layouts/claims_infobox.svelte'
  import EntityClaimsLinks from '#entities/components/layouts/entity_claims_links.svelte'
  import { infoboxShortlistPropertiesByType, infoboxPropertiesByType } from '#entities/components/lib/claims_helpers'
  import { omitClaims } from '#entities/components/lib/work_helpers'
  import type { SerializedEntitiesByUris } from '#entities/lib/entities'
  import Spinner from '#general/components/spinner.svelte'
  import type { ExtendedEntityType, PropertyUri, SimplifiedClaims } from '#server/types/entity'
  import { I18n } from '#user/lib/i18n'

  export let claims: SimplifiedClaims = {}
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

  let infoboxHeight, showDetails, infobox, waitingForEntities
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
    <ClaimsInfobox
      {allowlistedProperties}
      claims={displayedClaims}
      {relatedEntities}
      {entityType}
      {waitingForEntities}
    />
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
