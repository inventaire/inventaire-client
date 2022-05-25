<script>
  import { i18n } from '#user/lib/i18n'
  import { isNonEmptyArray } from '#lib/boolean_tests'
  import ClaimsInfobox from './claims_infobox.svelte'
  import { formatEntityClaim } from '#entities/components/lib/claims_helpers'

  export let entity, authorsUris, displayedClaims, claimsOrder

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
    <div class="claims-infobox">
      <ClaimsInfobox
        claims={displayedClaims}
        {claimsOrder}
      />
    </div>
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
  .claims-infobox{
    flex: 3 0 0;
    margin: 1em 0;
  }
  /*Large screens*/
  @media screen and (min-width: 1200px) {
    .title-box{
      // give space below edit data button when no cover
      margin: 0 0 0 1em;
    }
  }
  /*small and medium screens*/
  @media screen and (max-width: $small-screen) {
    .title-box{
      // give space below edit data button when no cover
      margin-right: 3em;
    }
  }
  /*Small screens*/
  @media screen and (max-width: $very-small-screen) {
    .infobox{
      @include display-flex(column, center);
    }
    .claims-infobox{
      margin: 1em 0;
    }
  }
</style>
