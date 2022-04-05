<script>
  import { I18n, i18n } from '#user/lib/i18n'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import { isNonEmptyArray } from '#lib/boolean_tests'
  import ClaimsInfobox from './claims_infobox.svelte'
  import ItemsLists from './items_lists.svelte'
  import EditionActions from './edition_actions.svelte'
  import EditDataActions from './edit_data_actions.svelte'
  import { aggregateWorksClaims, editionWorkProperties, formatEntityClaim } from '#entities/components/lib/claims_helpers'

  export let entity, works, standalone

  const { uri, image, label } = entity
  let { claims } = entity
  let displayedClaims = []
  let authorsUris

  const claimsOrder = [
    ...editionWorkProperties,
    'wdt:P2679', // author of foreword
    'wdt:P2680', // author of afterword
    'wdt:P655', // translator
    'wdt:P577', // date of publication
    'wdt:P1104', // number of pages
    'wdt:P123', // publisher
    'wdt:P212', // isbn 13
    'wdt:P957', // isbn 10
    'wdt:P407', // language
    'wdt:P629', // work
    'wdt:P195', // collection
    'wdt:P2635', // number of volumes
    'wdt:P856', // official website
  ]

  const addWorksClaims = (claims, works) => {
    const worksClaims = aggregateWorksClaims(claims, works)
    authorsUris = worksClaims['wdt:P50']
    delete worksClaims['wdt:P50']
    const nonEmptyWorksClaims = _.pick(worksClaims, isNonEmptyArray)
    return Object.assign(claims, nonEmptyWorksClaims)
  }

  const filterClaims = (_, key) => claimsOrder.includes(key)

  const claimsWithWorksClaims = _.pick(claims, filterClaims)

  displayedClaims = addWorksClaims(claimsWithWorksClaims, works)

  if (authorsUris) {
    delete displayedClaims['wdt:P50']
  }

  const subtitle = entity.claims['wdt:P1680']

  $: app.navigate(`/entity/${uri}`)
</script>
<div class="layout">
  {#if standalone}
    <h3 class="layout-type-label">{I18n(entity.type)}</h3>
  {/if}
  <div class="entity-wrapper">
    <EditDataActions {entity}/>
    <div class="entity">
      {#if image.url}
        <div class="cover">
          <img src="{imgSrc(image.url, 300)}" alt="{label}">
        </div>
      {/if}
      <div class="title-box">
        <h2 class="edition-title">{entity.claims['wdt:P1476']}</h2>
        {#if isNonEmptyArray(authorsUris)}
          <h3 class="edition-authors">
            {i18n('by')}
            {@html formatEntityClaim({ values: authorsUris, prop: 'wdt:P50', omitLabel: true })}
          </h3>
        {/if}
        {#if subtitle}
          <h4 class="edition-subtitle">{subtitle}</h4>
        {/if}
        <div class="info-wrapper">
          <div class="claims-infobox">
            <ClaimsInfobox claims={displayedClaims} {uri} {claimsOrder}/>
          </div>
        </div>
      </div>
      <div class="entity-buttons">
        <EditionActions {entity}/>
      </div>
    </div>
    <!-- TODO: works list -->
  </div>
  <div class="items-lists-wrapper">
    <ItemsLists {uri}/>
  </div>
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .layout{
    @include display-flex(column, center, center);
    margin: 0 auto;
    max-width: 80em;
    background-color: white;
  }
  .edition-title{
    margin: 0;
    padding: 0;
    font-weight: bold;
    font-size: 1.5em;
  }
  .edition-authors{
    margin-bottom: 0.5em;
    font-size: 1.2em;
  }
  .entity-wrapper{
    width: 100%;
    padding: 0 1em;
  }
  .entity{
    @include display-flex(row, stretch, space-between);
    margin-bottom: 2em;
  }
  .cover{
    @include display-flex(column, center);
    max-width: 20%;
    margin-bottom: 1em;
    margin-right: 1em;
  }
  .claims-infobox{
    flex: 3 0 0;
    margin-bottom: 2em;
  }
  .entity-buttons{
    @include display-flex(row, center, center);
  }
  /*small and medium screens*/
  @media screen and (max-width: $small-screen) {
    .entity-wrapper{
      width: unset;
    }
    .info-wrapper{
      @include display-flex(column, center);
    }
  }
  /*Small screens*/
  @media screen and (max-width: $smaller-screen) {
    .layout{
      @include display-flex(column, center, flex-start);
    }
    .title-box{
      max-width: 80%;
    }
    .entity-wrapper{
      width: 100%;
      padding: 0;
    }
    .entity{
      @include display-flex(column, center);
      min-width: 100%;
    }
    .claims-infobox{
      margin: 1em 0;
    }
    .cover{
      max-width: 50%;
      margin-right: 0;
    }
  }
</style>
