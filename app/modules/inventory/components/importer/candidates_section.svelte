<script>
  import { I18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import Counter from '#components/counter.svelte'
  import CandidateRow from '#inventory/components/importer/candidate_row.svelte'
  import screen_ from '#lib/screen'

  export let candidates
  export let processedPreCandidatesCount
  export let totalPreCandidates
  let selectedBooksCount, titleEl

  const checkAll = checked => candidates = candidates.map(candidate => ({ ...candidate, checked }))

  $: {
    if (processedPreCandidatesCount === totalPreCandidates && processedPreCandidatesCount > 0) {
      screen_.scrollToElement(titleEl.offsetTop)
    }
  }
  $: candidatesLength = candidates.length
  $: selectedBooksCount = candidates.filter(_.property('checked')).length
</script>
<h3 bind:this={titleEl}>2/ Select the books you want to add</h3>
<ul>
  {#each candidates as candidate (candidate.index)}
    <CandidateRow bind:candidate/>
  {/each}
</ul>
<div class="candidates-nav">
  <button class="grey-button" on:click="{() => checkAll(true)}" name="{I18n('select all')}">
    {I18n('select all')}
  </button>
  <button class="grey-button" on:click="{() => checkAll(false) }" name="{I18n('unselect all')}">
    {I18n('unselect all')}
  </button>
  <button class="grey-button" on:click="{() => candidates = []}" name="{I18n('empty the queue')}">
    <!-- TODO: insert "are you sure" popup -->
    {@html icon('trash')} {I18n('empty the queue')}
  </button>
</div>
{#if candidatesLength > 20 }
  <!-- repeat counter when many candidates -->
  <Counter total={totalPreCandidates} count={processedPreCandidatesCount}/>
  <!-- stats -->
  <p>{I18n('Number of books found')}: {candidatesLength}</p>
  <p>{I18n('Number of books you selected to import')}: {selectedBooksCount}</p>
{/if}
<style lang="scss">
  @import '#general/scss/utils';
  .candidates-nav{
    @include display-flex(row, center, center, wrap);
    button {
      @include radius;
      margin: 0.1em;
      flex: 1 0 0;
      padding: 0.5em;
      word-wrap: break-word;
      min-width: 10em;
    }
  }
  h3{
    font-weight: bold;
    margin-top: 1em;
  }
</style>
