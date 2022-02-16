<script>
  import CandidateActions from '#inventory/components/importer/candidate_actions.svelte'
  import ListItem from '#inventory/components/list_item.svelte'
  export let candidate
  export let processedCandidates
  export let listing
  export let transaction

  let { isbnData, edition, works, authors, error } = candidate
</script>
<li class="list-candidate" class:error>
  <ListItem
    {isbnData}
    {edition}
    {works}
    {authors}
    />
  <CandidateActions
    bind:candidate
    bind:processedCandidates
    {listing}
    {transaction}
  />
</li>
<style lang="scss">
  @import '#general/scss/utils';
  .error{
    background-color: rgba($warning-color, 0.3);
  }
  .list-candidate{
    @include display-flex(row, center, space-between);
    margin: 0.2em 0;
    padding: 0.5em 1em;
    border: solid 1px #ccc;
    border-radius: 3px;
  }
</style>
