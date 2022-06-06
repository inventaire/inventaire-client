<script>
  import { I18n } from '#user/lib/i18n'
  import { getEntitiesAttributesFromClaims } from '#entities/lib/entities'
  import ClaimInfobox from './claim_infobox.svelte'
  import WrapToggler from '#components/wrap_toggler.svelte'
  import Spinner from '#general/components/spinner.svelte'
  import { propertiesType } from '#entities/components/lib/claims_helpers'
  import log_ from '#lib/loggers'

  export let claims = {}, propertiesLonglist, propertiesShortlist

  let displayedProperties = propertiesShortlist
  let entitiesByUris
  let claimsLonglist = _.pick(claims, propertiesLonglist)
  let hasLonglistBeenDisplayed

  const waitingForEntities = getInfoboxEntities(displayedProperties)

  async function getInfoboxEntities () {
    let entitiesClaims = {}
    displayedProperties.forEach(prop => {
      if (claimsLonglist[prop] && (propertiesType[prop] === 'entityProp')) {
        entitiesClaims[prop] = claims[prop]
      }
    })
    entitiesByUris = await getEntitiesAttributesFromClaims(entitiesClaims)
  }

  const updateHasLonglistBeenDisplayed = () => {
    const isLonglistDisplayed = (displayedProperties === propertiesLonglist)
    if (!hasLonglistBeenDisplayed && isLonglistDisplayed) hasLonglistBeenDisplayed = true
  }

  $: (async () => {
    // early return if all entities have been fetched already
    if (hasLonglistBeenDisplayed) return
    // lazy load propertiesLonglist entities
    await getInfoboxEntities()
    // logging is a pretext to trigger function when claims or displayedProperties are updated
    if (displayedProperties) log_.info(displayedProperties, 'updated claims')
    updateHasLonglistBeenDisplayed()
  })()

  let showMore = true

  $: claimsLonglist = _.pick(claims, propertiesLonglist)
  $: claimsShortlist = _.pick(claims, propertiesShortlist)
  $: entityPropertiesLonglist = Object.keys(claimsLonglist)
  $: entityPropertiesShortlist = Object.keys(claimsShortlist)
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
