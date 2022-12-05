<script>
  import { I18n } from '#user/lib/i18n'
  import { isNonEmptyArray, isEntityUri } from '#lib/boolean_tests'
  import { getEntitiesAttributesByUris } from '#entities/lib/entities'
  import ClaimInfobox from './claim_infobox.svelte'
  import WrapToggler from '#components/wrap_toggler.svelte'
  import Spinner from '#general/components/spinner.svelte'
  import { infoboxPropsLists } from '#entities/components/lib/claims_helpers'
  import EntityClaimsLinks from '#entities/components/layouts/entity_claims_links.svelte'

  export let claims = {},
    relatedEntities = {},
    entityType,
    withShortlist,
    shortlistOnly

  // Which parent/consumer params for which behavior:
  // - display shortlist, longlist and toggler             => withShortlist = true
  // - display only longlists (no shortlist, no toggler)   => withShortlist = false
  // - display only shortlist (no longlist, no toggler)    => shortlistOnly = true

  // When longlist length is below longlistDisplayLimit, dont display shortlist
  let longlistDisplayLimit = 4
  let showMore = true

  const entityTypeClaimsLists = infoboxPropsLists[entityType]
  const propertiesLonglist = entityTypeClaimsLists?.long || []

  let propertiesShortlist
  if (withShortlist || shortlistOnly) propertiesShortlist = entityTypeClaimsLists?.short || []

  let displayedProperties = propertiesShortlist || propertiesLonglist
  let entityPropertiesShortlist, entityPropertiesLonglist

  async function getMissingEntities () {
    let missingUris = []
    displayedProperties.forEach(prop => {
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
  $: if (displayedProperties) {
    waitingForEntities = getMissingEntities()
  }
  $: displayToggler = !shortlistOnly && withShortlist && entityPropertiesLonglist.length > longlistDisplayLimit
  $: {
    if (withShortlist) {
      if (showMore) {
        displayedProperties = entityPropertiesShortlist
      } else {
        displayedProperties = entityPropertiesLonglist
      }
    }
  }
</script>
<div class="claims-infobox-wrapper">
  <div class="claims-infobox">
    {#each displayedProperties as prop}
      <ClaimInfobox
        values={claims[prop]}
        {prop}
        entitiesByUris={relatedEntities}
      />
    {/each}
    {#if !shortlistOnly}
      <EntityClaimsLinks claims={claims} />
    {/if}
  </div>
  {#if isNonEmptyArray(displayedProperties)}
    {#await waitingForEntities}
      <Spinner/>
    {/await}
  {/if}
  {#if displayToggler}
    <WrapToggler
      bind:show={showMore}
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
</style>
