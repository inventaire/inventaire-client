<script>
  import { i18n } from '#user/lib/i18n'
  import { loadInternalLink } from '#lib/utils'
  import { isPropertyUri } from '#lib/boolean_tests'

  export let label
  export let entitiesLength
  export let filteredEntitiesLength = null
  export let property = null
  export let uri = null
</script>
{#if label}
  <div class="label-wrapper">
    <div class="left-section">
      <h3>
        {label}
        {#if entitiesLength > 0}
          <span class="counter">
            {#if filteredEntitiesLength != null && filteredEntitiesLength >= 0 && filteredEntitiesLength !== entitiesLength}
              {filteredEntitiesLength} /
            {/if}
            {entitiesLength}
          </span>
        {/if}
      </h3>
    </div>
    {#if isPropertyUri(property)}
      <a
        class="show-advanced-list-browser"
        href={`/entity/${property}-${uri}`}
        on:click={loadInternalLink}
      >
        {i18n('Open in advanced list browser')}
      </a>
    {/if}
  </div>
{/if}
<style lang="scss">
  @import "#general/scss/utils";
  .label-wrapper{
    @include display-flex(row, center,space-between);
  }

  .left-section{
    @include display-flex(row, center);
  }
  h3{
    @include sans-serif;
    font-size: 1.1rem;
    margin: 0;
  }
  .show-advanced-list-browser{
    margin-inline-start: 2rem;
    @include shy;
    &:hover{
      text-decoration: underline;
    }
  }
  .counter{
    @include counter-commons;
    background-color: white;
    font-size: 1rem;
    margin-inline-start: 0.5em;
  }
</style>
