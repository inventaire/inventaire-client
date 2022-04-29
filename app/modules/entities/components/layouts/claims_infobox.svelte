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
<div class="claims">
  {#each claimsList as claimLi}
    <div>
      {@html claimLi}
    </div>
  {/each}
</div>
