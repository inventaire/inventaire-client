<script>
  import { I18n, i18n } from '#user/lib/i18n'
  import { isNonEmptyArray } from '#lib/boolean_tests'
  import ClaimsInfobox from './claims_infobox.svelte'
  import { formatEntityClaim } from '#entities/components/lib/claims_helpers'
  import WrapToggler from '#components/wrap_toggler.svelte'

  export let entity, authorsUris, displayedClaims, claimsOrder
  $: showLess = true
  const subtitle = entity.claims['wdt:P1680']
</script>
<div class="infobox">
  <div class="title-box">
    {#if subtitle}
      <h3>{subtitle}</h3>
    {/if}
    {#if isNonEmptyArray(authorsUris)}
      <h3 class="authors">
        {i18n('by')}
        {@html formatEntityClaim({ values: authorsUris, prop: 'wdt:P50', omitLabel: true })}
      </h3>
    {/if}
    <div
      class="claims-infobox"
      class:showLess={showLess}
    >
     <ClaimsInfobox
        claims={displayedClaims}
        {claimsOrder}
      />
    </div>
    {#if Object.keys(displayedClaims).length > 4}
      <WrapToggler
        bind:show={showLess}
        moreText={I18n('more details...')}
        lessText={I18n('less details')}
        reversedShow={true}
      />
    {/if}
  </div>
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .authors{
    margin-bottom: 0.5em;
    font-size: 1.1em;
    :global(.entity-value){
      @include link-dark;
    }
  }
  .showLess{
    max-height: 4.5em;
    overflow-y: hidden;
  }
  .claims-infobox{
    flex: 3 0 0;
  }
  .infobox{
    margin-bottom: 0.5em;
  }
  /*Large screens*/
  @media screen and (min-width: 1200px) {
    .title-box{
      // give space below edit data button when no cover
      margin: 0 0 0 1em;
    }
  }
  /*Small screens*/
  @media screen and (max-width: $very-small-screen) {
    .infobox{
      @include display-flex(column, center);
    }
    .infobox{
      margin-bottom: 0.5em;
    }
  }
</style>
