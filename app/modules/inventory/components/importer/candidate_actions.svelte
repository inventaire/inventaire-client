<script>
  import Spinner from '#general/components/spinner.svelte'
  import Flash from '#lib/components/flash.svelte'
  import app from '#app/app'
  import { I18n } from '#user/lib/i18n'
  import { createItem } from '#inventory/components/importer/lib/create_item'
  import { resolveAndCreateCandidateEntities } from '#inventory/lib/importer/import_helpers'

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

    await createItem(edition, details, transaction, visibility)
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
      const username = app.user.get('username')
      if (edition) itemPath = `/users/${username}/inventory/${edition.uri}`
    }
  }
</script>
{#if error}
  <button class='dangerous-button' on:click="{retryCreateItem}">
    {I18n('Retry')}
    {#if retrying}
      <Spinner/>
    {/if}
  </button>
{/if}
<Flash bind:state={flash}/>
{#if item}
  <a
    class="view-book tiny-button light-blue"
    href="{itemPath}"
    target="_blank"
    rel="noreferrer"
    >
      {I18n('View book')}
    </a>
{/if}
<style>
  .view-book{
    min-width: 6em;
    text-align: center;
  }
</style>
