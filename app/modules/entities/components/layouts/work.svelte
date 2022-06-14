<script>
  import Spinner from '#general/components/spinner.svelte'
  import { isNonEmptyArray } from '#lib/boolean_tests'
  import { I18n } from '#user/lib/i18n'
  import { getWorkProperties } from '#entities/components/lib/claims_helpers'
  import BaseLayout from './base_layout.svelte'
  import AuthorsInfo from './authors_info.svelte'
  import Infobox from './infobox.svelte'

  export let entity, standalone

  const omitAuthorsProperties = true
  const { uri } = entity

  const workShortlist = [
    'wdt:P577',
    'wdt:P136',
    'wdt:P921',
  ]

  $: claims = entity.claims
  $: notOnlyP31 = Object.keys(claims).length > 1
  $: app.navigate(`/entity/${uri}`)
</script>

<BaseLayout
  bind:entity={entity}
  {standalone}
>
  <div class="entity-layout" slot="entity">
    <div class="top-section">
      {#if notOnlyP31}
        <div class="work-section">
          <AuthorsInfo
            {claims}
          />
          <Infobox
            {claims}
            propertiesLonglist={getWorkProperties(omitAuthorsProperties)}
            propertiesShortlist={workShortlist}
          />
        </div>
      {/if}
    </div>
  </div>
</BaseLayout>

<style lang="scss">
  @import '#general/scss/utils';
  $entity-max-width: 650px;
  .entity-layout{
    @include display-flex(column, center);
    width: 100%;
  }
  .top-section{
    @include display-flex(row, flex-start, center);
    width: 100%;
  }
  .work-section{
    @include display-flex(column, flex-start);
    flex: 1 0 0;
    margin: 0 1em;
  }

  /*Small screens*/
  @media screen and (max-width: $small-screen) {
    .work-section{
      margin-left: 0;
      margin-right: 1em;
    }
  }

  /*Smaller screens*/
  @media screen and (max-width: $smaller-screen) {
    .top-section{
      @include display-flex(column);
    }
  }

  /*Small screens*/
  @media screen and (max-width: $smaller-screen) {
    .entity-layout{
      @include display-flex(column);
    }
  }
</style>
