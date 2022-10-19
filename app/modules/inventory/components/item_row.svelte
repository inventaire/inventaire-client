<script>
  import { i18n } from '#user/lib/i18n'
  import { icon, loadInternalLink } from '#lib/utils'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import { transactionsDataFactory } from '#inventory/lib/transactions_data'
  import { getVisibilitySummary, getVisibilitySummaryLabel, visibilitySummariesData } from '#general/lib/visibility'
  import { getDocStore } from '#lib/svelte/mono_document_stores'
  import { serializeItem } from '#inventory/lib/items'

  export let item, showUser

  const itemStore = getDocStore({ category: 'items', doc: item })

  const mainUserIsOwner = item.visibility != null

  const { pathname } = serializeItem(item)
  const title = item.snapshot['entity:title']
  const authors = item.snapshot['entity:authors']
  const image = item.snapshot['entity:image']

  let details, transaction, visibility, isPrivate, visibilitySummary, visibilitySummaryData, currentTransaction, username, picture, inventoryPathname
  $: {
    ;({ details = '', transaction, visibility } = $itemStore)
    if (mainUserIsOwner) {
      isPrivate = visibility.length === 0
      visibilitySummary = getVisibilitySummary(visibility)
      visibilitySummaryData = visibilitySummariesData[visibilitySummary]
    }
    currentTransaction = transactionsDataFactory()[transaction]
    if ($itemStore.user) {
      ;({ username, picture, inventoryPathname } = $itemStore.user)
    }
  }
</script>

<div class="item-row">
  <slot name="checkbox" />

  <a
    href="{pathname}"
    on:click|stopPropagation={loadInternalLink}
    class="show-item"
  >
    <div class="image-wrapper">
      {#if image}<img src="{imgSrc(image, 128)}" alt="">{/if}
    </div>
    <div class="info">
      <p class="title">{title}</p>
      <p class="authors">{authors || ''}</p>
    </div>
    {#if details}
      <p class="details">{details}</p>
    {/if}
  </a>

  {#if showUser && $itemStore.user}
    <a
      class="user"
      href={inventoryPathname}
      on:click|stopPropagation={loadInternalLink}
    >
      <img class="avatar" alt="{username} avatar" src="{imgSrc(picture, 48)}">
      <span class="username">{username}</span>
    </a>
  {/if}

  <div class="modes">
    {#if !isPrivate}
      <div class="transaction {currentTransaction.id}" title="{i18n(currentTransaction.labelPersonalized, item.user)}">
        {@html icon(currentTransaction.icon)}
      </div>
    {/if}
    {#if mainUserIsOwner}
      <div class="visibility {visibilitySummary}" title="{i18n(getVisibilitySummaryLabel(visibility))}">
        {@html icon(visibilitySummaryData.icon)}
      </div>
    {/if}
  </div>
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .item-row{
    position: relative;
    background-color: #fefefe;
    height: 4em;
    overflow: hidden;
    @include display-flex(row, center, center);
    :global(input[type="checkbox"]){
      padding: 1em;
      margin: 1em;
    }
  }
  .modes{
    @include display-flex(row, center, center);
    flex: 0 0 auto;
    > div{
      margin-left: 0.2em;
    }
  }
  .authors{
    color: $grey;
    @include text-ellipsis;
  }
  .details:not(:empty){
    background-color: #eee;
    padding: 0 0.5em;
    overflow: hidden;
    @include radius;
  }
  .transaction, .visibility, .avatar{
    @include radius;
    height: 2em;
    width: 2em;
  }
  .transaction, .visibility{
    @include display-flex(row, center, center);
    color: white;
  }
  .transaction{
    margin-left: 1em;
    &.giving{
      background-color: $giving-color;
    }
    &.lending{
      background-color: $lending-color;
    }
    &.selling{
      background-color: $selling-color;
    }
    &.inventorying{
      background-color: $inventorying-color;
    }
  }
  .visibility{
    &.private{
      background-color: $private-color;
    }
    &.network{
      background-color: $network-color;
    }
    &.public{
      color: $default-text-color;
      background-color: $public-color;
    }
  }
  .show-item{
    @include display-flex(row, center, flex-start);
    @include bg-hover(white, 5%);
    flex: 1 0 0;
    overflow: hidden;
    margin-right: 0.5em;
  }
  .user{
    @include bg-hover(white, 5%);
    align-self: stretch;
    margin: 0.2em 0;
    padding: 0 0.2em;
    @include display-flex(row, center, center);
  }
  .username{
    margin-left: 0.5em;
    @include serif;
  }

  /*Small screens*/
  @media screen and (max-width: $smaller-screen) {
    .item-row{
      margin-bottom: 1em;
      margin: 0.5em 0;
      padding: 0.2em;
    }
    a{
      flex-direction: column;
      align-self: stretch;
    }
    .info{
      align-self: stretch;
      text-align: center;
    }
    .details{
      max-height: 5em;
      margin: 0.5em;
    }
    .modes{
      flex-direction: column;
      > div{
        margin: 0.1em 0;
      }
    }
  }

  /*Large screens*/
  @media screen and (min-width: $smaller-screen) {
    .info{
      flex: 1 1 0;
      text-align: left;
      min-width: 40%;
      max-width: 30em;
    }
    .details{
      max-height: 3em;
      margin: 0 0.5em;
      flex: 1 1 auto;
    }
    .image-wrapper{
      margin-right: 0.5em;
      min-height: 3em;
      flex: 0 0 3em;
    }
    .transaction, .visibility, .user{
      margin-right: 0.5em;
    }
  }
</style>
