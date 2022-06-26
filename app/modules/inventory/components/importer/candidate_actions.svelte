<script>
  import Spinner from '#general/components/spinner.svelte'
  import Flash from '#lib/components/flash.svelte'
  import app from '#app/app'
  import { I18n } from '#user/lib/i18n'
  import { createItem } from '#inventory/components/create_item'
  import { resolveAndCreateCandidateEntities } from '#inventory/lib/importer/import_helpers'
  import { isOpenedOutside } from '#lib/utils'

  export let candidate
  export let listing
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

    await createItem(edition, details, transaction, listing)
    .then(newItem => {
      if (newItem) {
        candidate.error = undefined
        candidate.item = newItem
      }
    })
    .catch(err => candidate.error = err.responseJSON)
    .finally(() => retrying = false)
  }

  const viewBook = (e, itemId) => {
    if (!isOpenedOutside(e)) app.execute('show:item:byId', itemId)
  }

  $: {
    const username = app.user.get('username')
    if (edition) itemPath = `/inventory/${username}/${edition.uri}`
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
  <a class="view-book tiny-button light-blue" href="{itemPath}" target='_blank' on:click="{e => viewBook(e, item._id)}">
      {I18n('View book')}
    </a>
{/if}
<style>
  .view-book{
    min-width: 6em;
    text-align: center;
  }
</style>
