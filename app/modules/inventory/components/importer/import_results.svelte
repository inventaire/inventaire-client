<script>
  import { I18n } from '#user/lib/i18n'
  import ListItem from '#inventory/components/list_item.svelte'
  import CandidateActions from '#inventory/components/importer/candidate_actions.svelte'
  export let processedCandidates
  export let listing
  export let transaction
  $:candidatesErrors = processedCandidates.filter(_.property('error'))
  $:createdCandidates = processedCandidates.filter(_.property('item'))
</script>
{#if candidatesErrors.length > 0}
  <h4>{I18n('books not imported')}</h4>
  <ul>
    {#each candidatesErrors as candidate (candidate.index)}
      <li class="listCandidate candidateErr" >
        <ListItem {candidate}/>
        <CandidateActions
          bind:candidate
          bind:processedCandidates
          {listing}
          {transaction}
        />
      </li>
    {/each}
  </ul>
{/if}
{#if createdCandidates.length > 0}
  <h4>{I18n('books successfully added to your inventory')}</h4>
  <ul>
    {#each createdCandidates as candidate (candidate.index)}
      <li class="listCandidate" >
        <ListItem {candidate}/>
        <CandidateActions
          bind:candidate
          bind:processedCandidates
          {listing}
          {transaction}
        />
      </li>
    {/each}
  </ul>
{/if}

<style lang="scss">
  @import '#general/scss/utils';
  .candidateErr{
    background-color: rgba($warning-color, 0.3);
  }
  .listCandidate{
    @include display-flex(row, center, center);
    margin: 0.2em 0;
    padding: 0.5em 1em;
    border: solid 1px #ccc;
    border-radius: 3px;
  }
</style>
