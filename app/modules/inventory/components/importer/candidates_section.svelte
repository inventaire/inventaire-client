<script>
  import { I18n } from '#user/lib/i18n'
  import CandidateRow from '#inventory/components/importer/candidate_row.svelte'
  import CandidateNav from '#inventory/components/importer/candidate_nav.svelte'
  import screen_ from '#lib/screen'

  export let candidates
  export let processing
  let selectedBooksCount, titleEl

  $: {
    if (processing) screen_.scrollToElement(titleEl.offsetTop)
  }
  $: candidatesLength = candidates.length
  $: selectedBooksCount = candidates.filter(_.property('checked')).length
</script>
<h3 bind:this={titleEl}>2/ Select the books you want to add</h3>
{#if candidatesLength > 20 }
  <CandidateNav bind:candidates />
{/if}
<ul>
  {#each candidates as candidate (candidate.index)}
    <CandidateRow bind:candidate/>
  {/each}
</ul>
<CandidateNav bind:candidates />
{#if candidatesLength > 20 }
  <!-- stats -->
  <p>{I18n('Number of books found')}: {candidatesLength}</p>
  <p>{I18n('Number of books you selected to import')}: {selectedBooksCount}</p>
{/if}
<style>
  h3{
    font-weight: bold;
    margin-top: 1em;
  }
</style>
