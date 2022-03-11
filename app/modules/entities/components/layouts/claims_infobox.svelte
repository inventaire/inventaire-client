<script>
  export let claims
  import { formatClaim } from '#entities/components/lib/claims_helpers'

  const props = Object.keys(claims)
</script>
<div class="claims">
  {#each props as prop}
      {@html formatClaim(prop, claims)}
  {/each}
</div>
<style lang="scss">
  @import '#general/scss/utils';
  .claims{
    :global(.property-value){
      margin-right: 0.5em;
    };
  }
</style>
