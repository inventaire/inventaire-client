<script>
  import Flash from '#lib/components/flash.svelte'
  import Link from '#lib/components/link.svelte'
  import preq from '#lib/preq'
  import { i18n } from '#user/lib/i18n'

  export let entity

  const { uri } = entity

  let summaries = [], flash, selectedSummary

  const waiting = preq.get(app.API.data.summaries(uri))
    .then(res => {
      summaries = Object.values(res.summaries)
      selectedSummary = summaries[0]?.source
    })
    .catch(err => flash = err)

  $: summaryData = summaries.find(summaryData => summaryData.source === selectedSummary)
</script>

{#await waiting then}
  <div class="summary">
    {#if summaries.length > 1}
      <select bind:value={selectedSummary}>
        {#each summaries as summary (summary.source)}
          <option value={summary.source}>summary.source</option>
        {/each}
      </select>
    {/if}
    <p class="summary">{summaryData.text}</p>
    <p class="source">
      <Link url={summaryData.link} text={`${i18n('source:')} ${summaryData.source}`} classNames="link" />
    </p>
  </div>
{/await}

<Flash state={flash} />

<style lang="scss">
  @import '#general/scss/utils';
  .summary{
    max-width: 40em;
    padding: 0.5em;
    @include serif;
    // font-style: italic;
    @include radius;
    background-color: $off-white;
  }
  .source{
    color: $grey;
    text-align: end;
    :global(a){
      color: $grey;
    }
  }
</style>
