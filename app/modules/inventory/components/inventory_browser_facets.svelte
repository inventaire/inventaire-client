<script>
  import { i18n } from '#user/lib/i18n'
  import FacetSelector from '#general/components/facet_selector.svelte'

  export let facetsSelectors, facetsSelectedValues
</script>

<div class="selectors">
  {#each Object.keys(facetsSelectors) as sectionName}
    {#if !facetsSelectors[sectionName].disabled}
      <FacetSelector
        bind:value={facetsSelectedValues[sectionName]}
        options={facetsSelectors[sectionName].options}
        buttonLabel={i18n(sectionName)}
      />
    {/if}
  {/each}
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .selectors{
    @include display-flex(row, center, center, wrap);
    :global(.select-dropdown){
      min-width: 12em;
      /*Small screens*/
      @media screen and (max-width: $very-small-screen) {
        margin: 0.5em;
      }
      /*Large screens*/
      @media screen and (min-width: $very-small-screen) {
        margin: 1em 0.5em;
      }
    }
    :global(.dropdown-button){
      word-break: normal;
      @include bg-hover(white, 8%);
      @include radius;
      @include shy-border;
      padding: 0.5em 1em;
      font-weight: bold;
      color: $dark-grey;
    }
  }
  /*Small screens*/
  @media screen and (max-width: $smaller-screen) {
    .selectors{
      flex-direction: column;
    }
  }
</style>
