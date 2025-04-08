<script lang="ts">
  import Flash from '#app/lib/components/flash.svelte'
  import Spinner from '#components/spinner.svelte'
  import OtherEditions from '#entities/components/layouts/other_editions.svelte'
  import { addWorksEditions } from '#entities/components/lib/edition_layout_helpers'
  import { I18n, i18n } from '#user/lib/i18n'

  export let entity, works

  let flash, worksHaveOtherEditions

  const waitingForEditions = addWorksEditions(works)
    .then(() => {
      worksHaveOtherEditions = works.some(work => work.editions.length > 1)
    })
    .catch(err => flash = err)
</script>

{#await waitingForEditions}
  <p class="loading">
    {i18n('Looking for editions…')}
    <Spinner />
  </p>
{:then}
  {#if worksHaveOtherEditions}
    <h5 class="other-editions-title">
      {I18n('other editions')}
    </h5>
    <ul class="other-works-editions">
      {#each works as work (work.uri)}
        <OtherEditions
          currentEdition={entity}
          {work}
        />
      {/each}
    </ul>
  {/if}
{/await}

<Flash state={flash} />

<style lang="scss">
  @use '#general/scss/utils';
  .other-editions-title{
    @include sans-serif;
  }
  .other-works-editions{
    @include display-flex(row, initial, space-around, wrap);
  }
</style>
