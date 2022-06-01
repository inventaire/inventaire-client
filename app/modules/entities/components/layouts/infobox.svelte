<script>
  import { I18n } from '#user/lib/i18n'
  import { getEntitiesAttributesFromClaims } from '#entities/lib/entities'
  import ClaimInfobox from './claim_infobox.svelte'
  import WrapToggler from '#components/wrap_toggler.svelte'
  import Spinner from '#general/components/spinner.svelte'
  import { propertiesType } from '#entities/components/lib/claims_helpers'

  export let claims = {}, propertiesLonglist, propertiesShortlist

  const claimsLonglist = _.pick(claims, propertiesLonglist)
  const claimsShortlist = _.pick(claims, propertiesShortlist)
  const entityPropertiesLonglist = Object.keys(claimsLonglist)
  const entityPropertiesShortlist = Object.keys(claimsShortlist)

  let displayedProperties = propertiesShortlist

  let entitiesByUris

  const waitingForEntities = getInfoboxEntities(displayedProperties)
  async function getInfoboxEntities () {
    let entitiesClaims = {}
    // lazy load propertiesLonglist entities when triggering showMore
    displayedProperties.forEach(prop => {
      if (claimsLonglist[prop] && (propertiesType[prop] === 'entityProp')) {
        entitiesClaims[prop] = claims[prop]
      }
    })
    entitiesByUris = await getEntitiesAttributesFromClaims(entitiesClaims)
  }

  let hasLonglistBeenDisplayed
  $: (async () => {
    // early return if all entities have been fetched already
    if (hasLonglistBeenDisplayed) return
    await getInfoboxEntities()
    const isLonglistDisplayed = (displayedProperties === propertiesLonglist)
    if (!hasLonglistBeenDisplayed && isLonglistDisplayed) hasLonglistBeenDisplayed = true
  })()

  let showMore = true
  $: {
    if (showMore) {
      displayedProperties = entityPropertiesShortlist
    } else {
      displayedProperties = entityPropertiesLonglist
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
            {entitiesByUris}
            propType={propertiesType[prop]}
          />
        {/if}
      {/each}
    </div>
    {#if entityPropertiesShortlist.length !== entityPropertiesLonglist.length}
      <WrapToggler
        bind:show={showMore}
        moreText={I18n('more details...')}
        lessText={I18n('less details')}
        reversedShow={true}
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
