<script>
  import Link from '#lib/components/link.svelte'
  import getFavoriteLabel from '#entities/lib/get_favorite_label'

  export let entity
  export let standalone = true

  const { uri, claims } = entity

  const subtitle = claims['wdt:P1680']

  $: favoriteLabel = getFavoriteLabel(entity)
</script>
<h2>
  {#if standalone}
    {favoriteLabel}
  {:else}
    <Link
      url={`/entity/${uri}`}
      text={favoriteLabel}
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
