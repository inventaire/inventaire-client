<script>
  import { I18n } from '#user/lib/i18n'
  import { isNonEmptyArray, isEntityUri } from '#lib/boolean_tests'
  import { getEntitiesAttributesByUris } from '#entities/lib/entities'
  import ClaimInfobox from './claim_infobox.svelte'
  import WrapToggler from '#components/wrap_toggler.svelte'
  import Spinner from '#general/components/spinner.svelte'
  import { propertiesType } from '#entities/components/lib/claims_helpers'
  import log_ from '#lib/loggers'

  export let claims = {},
    propertiesLonglist,
    propertiesShortlist,
    relatedEntities = {},
    compactView

  let displayedProperties = propertiesShortlist
  let entitiesByUris = relatedEntities
  let claimsLonglist = _.pick(claims, propertiesLonglist)
  let hasLonglistBeenDisplayed

  const waitingForEntities = getMissingEntities(displayedProperties)

  async function getMissingEntities () {
    let missingUris = []
    displayedProperties.forEach(prop => {
      if (claimsLonglist[prop]) {
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
      entitiesByUris = { ...entitiesByUris, ...entities }
    }
  }

  const updateHasLonglistBeenDisplayed = () => {
    const isLonglistDisplayed = (displayedProperties === propertiesLonglist)
    if (!hasLonglistBeenDisplayed && isLonglistDisplayed) hasLonglistBeenDisplayed = true
  }

  $: (async () => {
    await getMissingEntities()
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
