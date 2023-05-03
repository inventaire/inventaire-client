<script>
  import { isNonEmptyArray } from '#lib/boolean_tests'
  import Link from '#lib/components/link.svelte'

  export let occurence

  const { contexts = [], matchedTitles, url } = occurence
  const domain = url.split('https://')[1].split('.wikipedia.org')[0]
</script>
{#if isNonEmptyArray(contexts)}
  <div class="contexts">
    <div class="title">
      <h4>
        {matchedTitles.join(', ')}
      </h4>
      <Link {url} text={`(${domain})`} />
    </div>
    {#each contexts as context}
      <div class="context">
        {context}
      </div>
    {/each}
  </div>
{/if}

<style lang="scss">
  @import "#general/scss/utils";
  .contexts{
    margin: 1em;
  }
  .context{
    background-color: $off-white;
    padding: 0.5em 1em;
    margin: 0.5em 0;
  }
  .title{
    @include display-flex(row, center);
  }
  h4{
    font-weight: bold;
    margin-right: 0.5em;
  }
</style>
