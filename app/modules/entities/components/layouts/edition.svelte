<script>
  import { isNonEmptyArray } from '#lib/boolean_tests'
  import Infobox from './infobox.svelte'
  import BaseLayout from './base_layout.svelte'
  import EditionActions from './edition_actions.svelte'
  import ItemsLists from './items_lists.svelte'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import {
    getTitle,
    aggregateWorksClaims,
    editionWorkProperties,
    editionProperties,
  } from '#entities/components/lib/claims_helpers'

  export let entity, works, standalone

  const { uri, image } = entity
  let { claims } = entity
  let displayedClaims = []
  let authorsUris

  const claimsOrder = [
    ...editionProperties,
    ...editionWorkProperties,
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

  const title = getTitle(entity)

  $: app.navigate(`/entity/${uri}`)
</script>
<BaseLayout
  {entity}
  {standalone}
>
  <div class="entity-layout" slot="entity">
    <div class="top-section">
      <div class="info">
        {#if image.url}
          <div class="cover">
            <img src="{imgSrc(image.url, 300)}" alt="{title}">
          </div>
        {/if}
        <Infobox
          {entity}
          {title}
          {authorsUris}
          {displayedClaims}
          {claimsOrder}
        />
      </div>
      <div class="edition-actions">
        <EditionActions {entity}/>
      </div>
    </div>
    <div class="items-lists-wrapper">
      <ItemsLists editionsUris={[ uri ]}/>
    </div>
  </div>
</BaseLayout>
<!-- TODO: works list -->

<style lang="scss">
  @import '#general/scss/utils';
  .info{
    @include display-flex(row, flex-start, center);
    margin-bottom: 1em;
  }
  .cover{
    padding-right: 1em;
    max-width: 12em;
  }
  .top-section{
    @include display-flex(row, center, space-between);
  }
  /*Large screens*/
  @media screen and (min-width: $small-screen) {
    .top-section{
      @include display-flex(row, center, space-around);
    }
  }
  /*Small screens*/
  @media screen and (max-width: $small-screen) {
    .top-section{
      @include display-flex(column, flex-start);
      padding-top: 1em;
    }
    .edition-actions{
      @include display-flex(column, center);
      width: 100%;
    }
  }
</style>
