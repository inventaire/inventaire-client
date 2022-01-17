<script>
  import { I18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import Spinner from '#components/spinner.svelte'
  import CandidateRow from '#inventory/components/importer/candidate_row.svelte'
  export let candidates
  export let preCandidatesCount
  let selectedBooksCount

  const checkAll = checked => candidates = candidates.map(candidate => ({ ...candidate, checked }))

  $: candidatesLength = candidates.length
  $: selectedBooksCount = candidates.filter(_.property('checked')).length
</script>
<h3>2/ Select the books you want to add</h3>
{#if candidatesLength > 0 && candidatesLength < preCandidatesCount}
  <p class="loading">
    {candidatesLength}/{preCandidatesCount}
    <Spinner/>
  </p>
{/if}
<ul>
  {#each candidates as candidate}
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
  {#if candidatesLength < preCandidatesCount}
    <p class="loading">
      {candidatesLength}/{preCandidatesCount}
      <Spinner/>
    </p>
  {/if}
  <!-- stats -->
  <p>{I18n('Number of books found')}: {candidatesLength}</p>
  <p>{I18n('Number of selected books')}: {selectedBooksCount}</p>
{/if}
<style lang="scss">
  @import 'app/modules/general/scss/utils';
  .candidates-nav{
    margin: 1em;
    @include display-flex(row, center, center, wrap);
    button { margin: 0.5em;}
  }
</style>
