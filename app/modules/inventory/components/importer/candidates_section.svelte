<script>
  import { property } from 'underscore'
  import CandidateNav from '#inventory/components/importer/candidate_nav.svelte'
  import CandidateRow from '#inventory/components/importer/candidate_row.svelte'
  import { scrollToElement } from '#lib/screen'
  import { I18n, i18n } from '#user/lib/i18n'

  export let candidates
  export let processing
  let selectedBooksCount, titleEl

  $: {
    if (processing) scrollToElement(titleEl)
  }
  $: candidatesLength = candidates.length
  $: selectedBooksCount = candidates.filter(property('checked')).length
</script>
<h3 bind:this={titleEl}>2/ {i18n('Select the books you want to add')}</h3>
{#if candidatesLength > 20}
  <CandidateNav bind:candidates />
{/if}
<ul>
  {#each candidates as candidate (candidate.index)}
    <CandidateRow bind:candidate />
  {/each}
</ul>
<CandidateNav bind:candidates />
{#if candidatesLength > 20}
  <p>{I18n('Number of books found')}: {candidatesLength}</p>
  <p>{I18n('Number of books you selected to import')}: {selectedBooksCount}</p>
{/if}
<style>
  h3{
    font-weight: bold;
    margin-block-start: 1em;
  }
</style>
