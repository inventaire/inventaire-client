<script>
  import ResultCandidate from '#inventory/components/importer/result_candidate.svelte'
  import { I18n } from '#user/lib/i18n'

  export let processedCandidates
  export let visibility
  export let transaction

  $:candidatesErrors = processedCandidates.filter(_.property('error'))
  $:createdCandidates = processedCandidates.filter(_.property('item'))
</script>
{#if candidatesErrors.length > 0}
  <h4>{I18n('books not imported')}</h4>
  <ul>
    {#each candidatesErrors as candidate (candidate.index)}
      <ResultCandidate {candidate} {visibility} {transaction} />
    {/each}
  </ul>
{/if}
{#if createdCandidates.length > 0}
  <h4>{I18n('books successfully added to your inventory')}</h4>
  <ul>
    {#each createdCandidates as candidate (candidate.index)}
      <ResultCandidate {candidate} {visibility} {transaction} />
    {/each}
  </ul>
{/if}
<style>
  ul{
    width: 100%;
  }
  h4{
    margin-block-start: 1em;
    display: flex;
    justify-content: center;
  }
</style>
