<script lang="ts">
  import { isNonEmptyArray } from '#app/lib/boolean_tests'
  import Flash from '#app/lib/components/flash.svelte'
  import { screen } from '#app/lib/components/stores/screen'
  import type { UserLang } from '#app/lib/languages/languages'
  import Spinner from '#components/spinner.svelte'
  import ItemsCascade from '#inventory/components/items_cascade.svelte'
  import ItemsTable from '#inventory/components/items_table.svelte'
  import { getRecentPublicItems } from '#inventory/lib/queries'
  import type { SerializedItem } from '#server/types/item'
  import { getCurrentLang, i18n } from '#user/lib/i18n'

  export let items: SerializedItem[] = []
  export let waitingForItems

  const params = {
    lang: getCurrentLang() as UserLang,
    assertImage: true,
    items: [],
  }

  let flash

  const waiting = getRecentPublicItems(params)
    .catch(err => {
      if (err.message !== 'no item found') flash = err
    })
</script>

<div class="some-public-books" class:empty={items.length === 0}>
  {#if waitingForItems}
    {#await waitingForItems}
      <div class="spinner-wrapper">
        <Spinner center={true} />
      </div>
    {:then}
      <section>
        <h3>{i18n('Some books in this area')}</h3>
        {#if $screen.isSmallerThan('$smaller-screen')}
          <ItemsTable {items} haveSeveralOwners={true} />
        {:else}
          <ItemsCascade {items} />
        {/if}
        <div class="fade-out" />
      </section>
    {/await}
  {:else}
    {#await waiting}
      <div class="spinner-wrapper">
        <Spinner center={true} />
      </div>
    {:then}
      {#if isNonEmptyArray(params.items)}
        <section>
          <h3>{i18n('Some of the last books listed')}</h3>
          {#await waiting}
            <Spinner center={true} />
          {:then}
            {#if $screen.isSmallerThan('$smaller-screen')}
              <ItemsTable items={params.items} {waiting} haveSeveralOwners={true} />
            {:else}
              <ItemsCascade items={params.items} {waiting} />
            {/if}
          {/await}
          <div class="fade-out" />
        </section>
      {/if}
    {/await}
  {/if}
  <Flash state={flash} />
</div>

<style lang="scss">
  @import "#welcome/scss/welcome_layout_commons";

  .some-public-books{
    min-height: 1rem;
    @include transition(min-height);
    &:not(.empty){
      min-height: 80vh;
    }
    background-color: $off-white;
  }

  .spinner-wrapper{
    min-height: 20em;
    @include display-flex(colum, center, center);
  }

  section{
    overflow: hidden;
    max-height: 150vh;
    overflow-y: hidden;
    position: relative;
  }
  .fade-out{
    position: absolute;
    inset-block-end: 0;
    inset-inline: 0;
    background: linear-gradient(0deg, $off-white, 50%, transparent);
    height: 5em;
  }
  /* Large screens */
  @media screen and (width >= $smaller-screen){
    section{
      padding: 0 1em;
    }
  }
  // Do not override item_card style
  h3:not(.title){
    text-align: center;
    font-size: 1.2em;
    margin-block-start: 0.5em;
  }
</style>
