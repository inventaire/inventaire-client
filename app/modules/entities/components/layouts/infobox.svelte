<script>
  import { I18n } from '#user/lib/i18n'
  import { isNonEmptyArray, isEntityUri } from '#lib/boolean_tests'
  import { getEntitiesAttributesByUris } from '#entities/lib/entities'
  import ClaimInfobox from './claim_infobox.svelte'
  import WrapToggler from '#components/wrap_toggler.svelte'
  import Spinner from '#general/components/spinner.svelte'
  import { infoboxShortlistPropertiesByType, infoboxPropertiesByType } from '#entities/components/lib/claims_helpers'
  import EntityClaimsLinks from '#entities/components/layouts/entity_claims_links.svelte'

  export let claims = {},
    relatedEntities = {},
    entityType,
    shortlistOnly,
    listDisplay

  let allowlistedProperties
  let infoboxPropertiesToDisplay = infoboxPropertiesByType[entityType]

  if (shortlistOnly) {
    allowlistedProperties = infoboxShortlistPropertiesByType[entityType] || infoboxPropertiesToDisplay
  } else {
    allowlistedProperties = infoboxPropertiesToDisplay
  }
  allowlistedProperties = allowlistedProperties || []

  async function getMissingEntities () {
    let missingUris = []
    allowlistedProperties.forEach(prop => {
      if (claims[prop]) {
        const propMissingUris = claims[prop].filter(value => {
          if (isEntityUri(value)) return !relatedEntities[value]
        })
        missingUris.push(...propMissingUris)
      }
    })
    if (isNonEmptyArray(missingUris)) {
      const { entities } = await getEntitiesAttributesByUris({
        uris: missingUris,
        attributes: [ 'labels', 'type' ],
        lang: app.user.lang
      })
      relatedEntities = { ...relatedEntities, ...entities }
    }
  }
  let waitingForEntities
  $: if (allowlistedProperties) {
    waitingForEntities = getMissingEntities()
  }

  let infoboxHeight, showDetails, infobox
  const wrappedInfoboxHeight = 128
  $: infoboxHeight = infobox?.clientHeight
  $: wrappedSize = listDisplay && infoboxHeight && infoboxHeight > wrappedInfoboxHeight
</script>
<div class="claims-infobox-wrapper">
  <div
    bind:this={infobox}
    class:wrapped-size={wrappedSize && !showDetails}
    class="claims-infobox"
  >
    {#each allowlistedProperties as prop}
      <ClaimInfobox
        values={claims[prop]}
        {prop}
        entitiesByUris={relatedEntities}
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
