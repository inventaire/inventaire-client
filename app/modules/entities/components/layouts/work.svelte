<script>
  import { I18n, i18n } from '#user/lib/i18n'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import { isNonEmptyArray } from '#lib/boolean_tests'
  import Spinner from '#general/components/spinner.svelte'
  import { getSubEntities } from '../lib/entities'

  import ClaimsInfobox from './claims_infobox.svelte'
  import ItemsLists from './items_lists.svelte'
  import EditionActions from './edition_actions.svelte'
  import EditDataActions from './edit_data_actions.svelte'

  import {
    editionWorkProperties,
    formatEntityClaim,
  } from '#entities/components/lib/claims_helpers'

  export let entity, standalone

  const { uri, image, label } = entity
  let { claims } = entity
  let displayedClaims = []
  let authorsUris
  let editions = []

  const claimsOrder = [
    ...editionWorkProperties,
    'wdt:P856', // official website
  ]

  const getEditions = async () => getSubEntities('work', uri)

  const addClaims = claims => {
    authorsUris = claims['wdt:P50']
    delete claims['wdt:P50']
    const nonEmptyClaims = _.pick(claims, isNonEmptyArray)
    return Object.assign(claims, nonEmptyClaims)
  }

  const filterClaims = (_, key) => claimsOrder.includes(key)

  const workClaims = _.pick(claims, filterClaims)

  displayedClaims = addClaims(workClaims)

  if (authorsUris) {
    delete displayedClaims['wdt:P50']
  }

  $: app.navigate(`/entity/${uri}`)
  $: editionsUris = editions.map(_.property('uri'))
</script>
<div class="layout">
  {#if standalone}
    <h3 class="layout-type-label">{I18n(entity.type)}</h3>
  {/if}
  <div class="entity-wrapper">
    <EditDataActions {entity} />
    <div class="entity">
      {#if image.url}
        <div class="cover">
          <img src="{imgSrc(image.url, 300)}" alt="{label}">
        </div>
      {/if}
      <div class="title-box">
        <h2 class="edition-title">{entity.label}</h2>
        {#if isNonEmptyArray(authorsUris)}
          <h3 class="edition-authorsUris">
            {i18n('by')}
            {@html formatEntityClaim({ values: authorsUris, prop: 'wdt:P50', omitLabel: true })}
          </h3>
        {/if}
        <div class="info-wrapper">
          <div class="claims-infobox">
            <ClaimsInfobox claims={displayedClaims} {uri} {claimsOrder}/>
          </div>
          <div class="entity-buttons">
            <EditionActions {entity}/>
          </div>
        </div>
      </div>
    </div>
    <!-- TODO: works list -->
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
  .edition-authorsUris{
    margin-bottom: 0.5em;
    font-size: 1.2em;
  }
  .entity-wrapper{
    width: 100%;
    padding: 0 1em;
  }
  .entity{
    @include display-flex(row, stretch, stretch);
    margin-bottom: 2em;
  }
  .cover{
    @include display-flex(column, center);
    max-width: 20%;
    margin-bottom: 1em;
    margin-right: 1em;
  }
  .info-wrapper{
    @include display-flex(row, stretch, stretch);
    flex: 3 0 0;
    margin: 0;
    padding: 0 1em;
  }
  .claims-infobox{
    flex: 3 0 0;
    margin-bottom: 2em;
    margin-right: 2em;
  }
  .entity-buttons{
    @include display-flex(column, stretch);
    max-width: 15em;
  }
  /*small and medium screens*/
  @media screen and (max-width: $small-screen) {
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
      @include display-flex(column, center);
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
