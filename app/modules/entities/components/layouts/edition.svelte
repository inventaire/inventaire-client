<script>
  import { isNonEmptyArray } from '#lib/boolean_tests'
  import AuthorsInfo from './authors_info.svelte'
  import BaseLayout from './base_layout.svelte'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import getFavoriteLabel from '#entities/lib/get_favorite_label'
  import {
    aggregateWorksClaims,
    editionLonglist,
  } from '#entities/components/lib/claims_helpers'

  export let entity, works, standalone

  const { uri, image } = entity
  let { claims } = entity

  const addWorksClaims = (claims, works) => {
    const worksClaims = aggregateWorksClaims(works)
    const nonEmptyWorksClaims = _.pick(worksClaims, isNonEmptyArray)
    return Object.assign(claims, nonEmptyWorksClaims)
  }

  const filterClaims = (_, key) => editionLonglist.includes(key)

  const claimsWithWorksClaims = _.pick(claims, filterClaims)

  const title = getFavoriteLabel(entity)

  $: app.navigate(`/entity/${uri}`)
  $: claims = addWorksClaims(claimsWithWorksClaims, works)
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
            <img src={imgSrc(image.url, 300)} alt="{title}">
          </div>
        {/if}
        <div class="infobox">
          <AuthorsInfo
            {claims}
          />
        </div>
      </div>
    </div>
  </div>
</BaseLayout>
<!-- TODO: works list -->

<style lang="scss">
  @import '#general/scss/utils';
  .entity-layout{
    @include display-flex(column, center);
    width: 100%;
  }
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