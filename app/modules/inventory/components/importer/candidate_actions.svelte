<script lang="ts">
  import Flash from '#app/lib/components/flash.svelte'
  import Spinner from '#general/components/spinner.svelte'
  import { createItem } from '#inventory/components/importer/lib/create_item'
  import { resolveAndCreateCandidateEntities } from '#inventory/lib/importer/import_helpers'
  import { I18n } from '#user/lib/i18n'
  import { mainUser } from '#user/lib/main_user'

  export let candidate
  export let visibility
  export let transaction

  let retrying, itemPath, flash

  const { edition, details, error, item } = candidate

  const retryCreateItem = async () => {
    retrying = true
    if (!edition) {
      const candidateWithEntities = await resolveAndCreateCandidateEntities(candidate)
        .catch(err => flash = err)
      candidate = candidateWithEntities
    }

    await createItem({ edition, details, transaction, visibility })
      .then(newItem => {
        if (newItem) {
          delete candidate.error
          candidate.item = newItem
        }
      })
      .catch(err => candidate.error = err.responseJSON)
      .finally(() => retrying = false)
  }

  $: {
    if (candidate.item) {
      itemPath = `/items/${candidate.item._id}`
    } else {
      const username = mainUser.username
      if (edition) itemPath = `/users/${username}/inventory/${edition.uri}`
    }
  }
</script>
{#if error}
  <button class="dangerous-button" on:click={retryCreateItem}>
    {I18n('Retry')}
    {#if retrying}
      <Spinner />
    {/if}
  </button>
{/if}
<Flash bind:state={flash} />
<div class="action-buttons">
  {#if item}
    <a
      class="view-book tiny-button light-blue"
      href={itemPath}
      target="_blank"
      rel="noreferrer"
    >
      {I18n('View book')}
    </a>
  {/if}

  {#if edition}
    <a
      class="view-book tiny-button light-blue"
      href={`/entity/${edition.uri}/edit`}
      target="_blank"
      rel="noreferrer"
    >
      {I18n('Edit edition')}
    </a>
  {/if}
</div>
<style lang="scss">
  @use "#general/scss/utils";
  .action-buttons{
    min-width: 6em;
    @include display-flex(column, center);
  }
  .view-book{
    margin: 0.5em 0;
    text-align: center;
  }
</style>
