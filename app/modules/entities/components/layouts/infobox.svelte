<script>
  import { I18n } from '#user/lib/i18n'
  import { isNonEmptyArray, isEntityUri } from '#lib/boolean_tests'
  import { getEntitiesAttributesByUris } from '#entities/lib/entities'
  import ClaimInfobox from './claim_infobox.svelte'
  import WrapToggler from '#components/wrap_toggler.svelte'
  import Spinner from '#general/components/spinner.svelte'
  import {
    propertiesType,
    infoboxPropsLists,
  } from '#entities/components/lib/claims_helpers'

  export let claims = {},
    hasPropertiesShortlist,
    relatedEntities = {},
    compactView,
    entityType

  const entityTypeClaimsLists = infoboxPropsLists[entityType]
  const propertiesLonglist = entityTypeClaimsLists.long

  let propertiesShortlist
  if (hasPropertiesShortlist) propertiesShortlist = entityTypeClaimsLists.short

  let displayedProperties = propertiesShortlist || propertiesLonglist
  let entityPropertiesShortlist, entityPropertiesLonglist

  const waitingForEntities = getMissingEntities()

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
        attributes: [ 'labels' ],
        lang: app.user.lang
      })
      relatedEntities = { ...relatedEntities, ...entities }
    }
  }

  $: (async () => {
    if (displayedProperties) await getMissingEntities()
  })()

  let showLess = true
  $: {
    const claimsLonglist = _.pick(claims, propertiesLonglist)
    entityPropertiesLonglist = Object.keys(claimsLonglist)
    if (propertiesShortlist) {
      const claimsShortlist = _.pick(claims, propertiesShortlist)
      entityPropertiesShortlist = Object.keys(claimsShortlist)
    }
  }
  $: {
    if (hasPropertiesShortlist) {
      if (showLess) {
        displayedProperties = entityPropertiesShortlist
      } else {
        displayedProperties = entityPropertiesLonglist
      }
    }
  }
</script>
<div class="claims-infobox-wrapper">
  {#await waitingForEntities}
    <Spinner/>
  {:then}
    <div class="claims-infobox">
      {#each displayedProperties as prop}
        {#if claims[prop]}
          <ClaimInfobox
            values={claims[prop]}
            {prop}
            entitiesByUris={relatedEntities}
            propType={propertiesType[prop]}
          />
        {/if}
      {/each}
    </div>
    {#if hasPropertiesShortlist && entityPropertiesLonglist.length > 2}
      <WrapToggler
        bind:show={showLess}
        moreText={I18n('more details')}
        lessText={I18n('less details')}
        reversedShow={true}
        withIcon={!compactView}
      />
    {/if}
  {/await}
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .claims-infobox{
    flex: 3 0 0;
  }
</style>
