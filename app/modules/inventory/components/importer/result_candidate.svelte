<script lang="ts">
  import EntryDisplay from '#inventory/components/entry_display.svelte'
  import CandidateActions from '#inventory/components/importer/candidate_actions.svelte'
  import Flash from '#lib/components/flash.svelte'

  export let candidate
  export let visibility
  export let transaction

  const { isbnData, edition, works, authors, error } = candidate
  let flash
  $: { if (error) flash = { type: 'error', message: error.status_verbose } }
</script>
<li class="list-candidate" class:error>
  <div class="list-actions-wrapper">
    <EntryDisplay
      {isbnData}
      {edition}
      work={works[0]}
      {authors}
    />
    <CandidateActions
      bind:candidate
      {visibility}
      {transaction}
    />
  </div>
  {#if error}
    <Flash bind:state={flash} />
  {/if}
</li>
<style lang="scss">
  @import "#general/scss/utils";
  .error{
    background-color: rgba($warning-color, 0.3);
  }
  .list-candidate{
    @include display-flex(column);
    margin: 0.2em 0;
    padding: 0.5em 1em;
    border: solid 1px #ccc;
    border-radius: 3px;
  }
  .list-actions-wrapper{
    @include display-flex(row, center, space-between);
  }
</style>
