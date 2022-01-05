<script>
  import { host } from '#app/lib/urls'
  import { icon } from '#app/lib/utils'
  export let uri

  const unprefixify = uri => uri?.replace(/^wd:/, '')
</script>
<span class="entitySourceLogo" title="{uri}">
  {#if uri?.startsWith('wd:Q')}
    <a href="https://wikidata.org/wiki/{unprefixify(uri)}" target="_blank">{@html icon('wikidata')}</a>
  {:else if uri?.startsWith('inv:')}
    <a href="{host}/entity/{uri}" target="_blank">inv</a>
  {/if}
</span>

<style>
  .entitySourceLogo{
    font-family: "Alegreya", serif;
    vertical-align: super;
    font-weight: normal;
    font-style: normal;
    font-size: 0.8em ;
  }
</style>
