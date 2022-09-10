<script>
  import Link from '#lib/components/link.svelte'

  export let entity
  export let standalone = true

  const { uri, claims, label } = entity

  $: subtitle = claims['wdt:P1680']
</script>
<h2>
  {#if standalone}
    {label}
  {:else}
    <Link
      url={`/entity/${uri}`}
      text={label}
      dark={true}
    />
  {/if}
</h2>
{#if subtitle}
  <div class="subtitle">
    {subtitle}
  </div>
{/if}
<style>
  h2{
    margin: 0;
  }
  .subtitle{
    margin-bottom: 0.3em;
    color: #444;
  }
</style>
