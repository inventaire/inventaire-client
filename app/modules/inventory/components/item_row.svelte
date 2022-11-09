<script>
  import { i18n } from '#user/lib/i18n'
  import { icon, loadInternalLink } from '#lib/utils'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import { transactionsDataFactory } from '#inventory/lib/transactions_data'
  import { getVisibilitySummary, getVisibilitySummaryLabel, visibilitySummariesData } from '#general/lib/visibility'
  import { getDocStore } from '#lib/svelte/mono_document_stores'
  import { serializeItem } from '#inventory/lib/items'
  import { screen } from '#lib/components/stores/screen'
  import ImageDiv from '#components/image_div.svelte'

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

  <div class="middle">
    <a
      href="{pathname}"
      on:click|stopPropagation={loadInternalLink}
      class="show-item"
    >
      <ImageDiv url={image} size={128} />
      <div class="info">
        <p class="title">{title}</p>
        <p class="authors">{authors || ''}</p>
        {#if details && $screen.isSmallerThan('$smaller-screen')}
          <p class="details">{details}</p>
        {/if}
      </div>
      {#if details && $screen.isLargerThan('$smaller-screen')}
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
  </div>

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

  $item-row-height-base: 4em;

  .item-row{
    position: relative;
    background-color: #fefefe;
    @include display-flex(row, center, center);
    :global(input[type="checkbox"]){
      padding: 1em;
      margin: 1em;
    }
  }
  .middle{
    flex: 1;
    align-self: stretch;
    @include display-flex(row, center);
    :global(.image-div){
      flex: 0 0 3em;
      align-self: stretch;
      margin-right: 0.5em;
      max-height: $item-row-height-base;
    }
  }
  .modes{
    @include display-flex(row, center, center);
    flex: 0 0 auto;
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
    height: 2em;
    width: 2em;
  }
  .transaction, .visibility{
    @include display-flex(row, center, center);
    color: white;
  }
  .avatar{
    @include radius;
  }
  .transaction{
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
    min-height: 3rem;
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
      align-self: stretch;
      min-height: $item-row-height-base;
    }
    .show-item{
      align-self: stretch;
    }
    .info{
      text-align: left;
      padding: 0 0.5em;
    }
    .details{
      max-height: 3em;
      margin: 0.5em;
    }
    .modes{
      flex-direction: column;
      margin-right: 0.2em;
    }
    .transaction, .visibility{
      &:first-child{
        @include radius-top;
        margin-top: 0.2em;
      }
      &:last-child{
        @include radius-bottom;
        margin-bottom: 0.2em;
      }
    }
    .user{
      margin-right: 0.5em;
    }
  }

  /*Large screens*/
  @media screen and (min-width: $smaller-screen) {
    .item-row{
      height: $item-row-height-base;
      overflow: hidden;
    }
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
    .transaction, .visibility, .user{
      margin-right: 0.5em;
    }
    .transaction, .visibility{
      margin-left: 0.2em;
      @include radius;
    }
  }
</style>
