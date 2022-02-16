<script>
  import { icon } from '#app/lib/utils'
  export let entity
  const { uri } = entity
  let { pathname } = entity
  const wdIdPattern = /Q\d+/
  const invPrefixPattern = /[inv:][isbn:]/

  if (!pathname && uri) pathname = `/entity/${uri}`
</script>
{#if pathname}
  <span class="entity-source-logo" title="{uri}">
    <a on:click|stopPropagation href="{pathname}" target="_blank">
      {#if pathname?.match(wdIdPattern)}
        {@html icon('wikidata')}
      {:else if pathname?.match(invPrefixPattern)}
        inv
      {/if}
    </a>
  </span>
{/if}
<style>
  .entity-source-logo{
    font-family: "Alegreya", serif;
    vertical-align: super;
    font-weight: normal;
    font-style: normal;
    font-size: 0.8em ;
  }
</style>
