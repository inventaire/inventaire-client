<script>
  import { isNonEmptyArray } from '#lib/boolean_tests'
  import AuthorsInfo from './authors_info.svelte'
  import Infobox from './infobox.svelte'
  import BaseLayout from './base_layout.svelte'
  import EditionActions from './edition_actions.svelte'
  import ItemsLists from './items_lists.svelte'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import {
    getTitle,
    aggregateWorksClaims,
    editionProperties,
  } from '#entities/components/lib/claims_helpers'

  export let entity, works, standalone

  const { uri, image } = entity
  let { claims } = entity

  const removeFromList = (list, el) => {
    const index = list.indexOf(el)
    list.splice(index, 1)
  }

  let editionLonglist = [
    ...editionProperties,
    'wdt:P179', // series
  ]
  removeFromList(editionLonglist, 'invp:P2')
  removeFromList(editionLonglist, 'wdt:P1476')

  const editionShortlist = [
    'wdt:P1680',
    'wdt:P577',
    'wdt:P123',
    'wdt:P212',
    'wdt:P179',
  ]

  const addWorksClaims = (claims, works) => {
    const worksClaims = aggregateWorksClaims(works)
    const nonEmptyWorksClaims = _.pick(worksClaims, isNonEmptyArray)
    return Object.assign(claims, nonEmptyWorksClaims)
  }

  const filterClaims = (_, key) => editionLonglist.includes(key)

  const claimsWithWorksClaims = _.pick(claims, filterClaims)

  claims = addWorksClaims(claimsWithWorksClaims, works)

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
        <div class="infobox">
          <AuthorsInfo
            {claims}
          />
          <Infobox
            {claims}
            propertiesLonglist={editionLonglist}
            propertiesShortlist={editionShortlist}
          />
        </div>
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
      margin:0 5em;
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
  /*Very mall screens*/
  @media screen and (max-width: $very-small-screen) {
    .infobox{
      width:100%;
    }
    .info{
      @include display-flex(column, center);
    }
  }
</style>
