<script>
  export let entity
</script>

<div>
  {#each Object.entries(entity.claims) as [ property, propertyClaims ]}
    <p>claim: {property} => {propertyClaims.join(', ')}</p>
  {/each}
</div>
