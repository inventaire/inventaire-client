<script>
  export let claims
  export let claimsOrder = []

  import { formatClaim } from '#entities/components/lib/claims_helpers'

  let claimsList = []

  const addClaim = prop => {
    const values = claims[prop]
    if (values) return formatClaim({ prop, values })
  }

  $: claimsList = _.compact(claimsOrder.map(addClaim))
</script>
{#each claimsList as claimLi}
  <div class="claim">
    {@html claimLi}
  </div>
{/each}

<style lang="scss">
  @import '#general/scss/utils';
  .claim{
    padding-bottom:0.2em;
  }
</style>
