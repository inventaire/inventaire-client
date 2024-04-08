<script lang="ts">
  import app from '#app/app'
  import FullScreenLoader from '#components/full_screen_loader.svelte'
  import Spinner from '#components/spinner.svelte'
  import Patch from '#entities/components/patches/patch.svelte'
  import { getEntityBasicInfoByUri } from '#entities/lib/entities'
  import { getEntityPatches } from '#entities/lib/patches'
  import { isCouchUuid } from '#lib/boolean_tests'
  import Flash from '#lib/components/flash.svelte'
  import { newError } from '#lib/error'
  import { loadInternalLink } from '#lib/utils'
  import { I18n } from '#user/lib/i18n'

  export let uri

  let pathname, label, flash, patches, entityId

  const waitForEntityBasicInfo = getEntityBasicInfoByUri(uri)
    .then(entity => {
      pathname = entity.pathname
      label = entity.label
      entityId = entity._id
    })
    .catch(err => flash = err)

  async function fetchPatches () {
    const id = uri.split(':')[1]
    if (isCouchUuid(id)) {
      entityId = id
    } else {
      await waitForEntityBasicInfo
    }
    if (isCouchUuid(entityId)) {
      patches = await getEntityPatches(entityId)
    } else {
      app.execute('show:error', newError('invalid entity id', { entityId }))
    }
  }

  const waitingForPatches = fetchPatches()
    .catch(err => flash = err)
</script>

<Flash state={flash} />

{#await waitForEntityBasicInfo}
  <FullScreenLoader />
{:then}
  <div class="entity-history">
    <div class="header">
      <h2>
        <a class="link" href={pathname} on:click={loadInternalLink}>
          {label}
        </a>
        - {I18n('history')}
      </h2>
      <span class="uri">{uri}</span>
    </div>

    {#await waitingForPatches}
      <Spinner center={true} />
    {:then}
      <ul>
        {#each patches as patch}
          <Patch {patch} />
        {/each}
      </ul>
    {/await}
  </div>
{/await}

<style lang="scss">
  @import "#general/scss/utils";

  .entity-history{
    color: white;
    max-width: 50em;
    margin: 0 auto;
  }
  .header{
    margin: 0.5em 1em;
  }
  .uri{
    font-size: 1rem;
  }
</style>
