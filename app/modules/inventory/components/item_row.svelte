<script lang="ts">
  import { createEventDispatcher } from 'svelte'
  import { compact } from 'underscore'
  import { isNonEmptyArray } from '#app/lib/boolean_tests'
  import { screen } from '#app/lib/components/stores/screen'
  import { imgSrc } from '#app/lib/handlebars_helpers/images'
  import { icon } from '#app/lib/icons'
  import { BubbleUpComponentEvent } from '#app/lib/svelte/svelte'
  import { isOpenedOutside, loadInternalLink } from '#app/lib/utils'
  import type { ShelvesByIds } from '#app/types/shelf'
  import ImageDiv from '#components/image_div.svelte'
  import { getVisibilitySummary, getVisibilitySummaryLabel, visibilitySummariesData } from '#general/lib/visibility'
  import ItemShowModal from '#inventory/components/item_show_modal.svelte'
  import { getItemLinkTitle, serializeItem } from '#inventory/lib/items'
  import { transactionsDataFactory } from '#inventory/lib/transactions_data'
  import { i18n } from '#user/lib/i18n'
  import ShelfDot from './shelf_dot.svelte'

  export let item
  export let showUser = false
  export let shelfId = null
  export let shelvesByIds: ShelvesByIds = null

  const mainUserIsOwner = item.visibility != null

  const { title, authors, image, pathname } = serializeItem(item)

  let details,
    transaction,
    visibility,
    isPrivate,
    visibilitySummary,
    visibilitySummaryData,
    currentTransaction,
    username,
    picture,
    userProfilePathname,
    itemShelvesIds,
    itemShelves

  $: {
    ;({ details = '', transaction, visibility, shelves: itemShelvesIds = [] } = item)
    if (mainUserIsOwner) {
      isPrivate = visibility.length === 0
      visibilitySummary = getVisibilitySummary(visibility)
      visibilitySummaryData = visibilitySummariesData[visibilitySummary]
    }
    currentTransaction = transactionsDataFactory()[transaction]
    if (item.user) {
      ;({ username, picture, pathname: userProfilePathname } = item.user)
    }
    if (shelvesByIds) {
      itemShelves = compact(itemShelvesIds.map(shelfId => shelvesByIds[shelfId]))
    }
  }

  let showItemModal
  function showItem (e) {
    if (isOpenedOutside(e)) return
    showItemModal = true
    e.preventDefault()
  }

  $: linkTitle = getItemLinkTitle({ title, mainUserIsOwner, username })

  const dispatch = createEventDispatcher()
  const bubbleUpComponentEvent = BubbleUpComponentEvent(dispatch)
</script>

<div
  class="item-row"
  class:removed-from-shelf={shelfId != null && !item.shelves.includes(shelfId)}
>
  <slot name="checkbox" />

  <div class="middle">
    <a
      href={pathname}
      on:click|stopPropagation={showItem}
      class="show-item"
      title={linkTitle}
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

    {#if showUser && item.user}
      <a
        class="user"
        href={userProfilePathname}
        on:click={loadInternalLink}
      >
        <span class="username">{username}</span>
        <img
          class="avatar"
          alt="{username} avatar"
          src={imgSrc(picture, 48)}
          loading="lazy"
        />
      </a>
    {/if}
  </div>

  {#if isNonEmptyArray(itemShelves)}
    <ul class="shelves-dots">
      {#each itemShelves as shelf (shelf._id)}
        <ShelfDot {shelf} on:selectShelf={bubbleUpComponentEvent} />
      {/each}
    </ul>
  {/if}
  <div class="modes">
    {#if !isPrivate}
      <div class="transaction {currentTransaction.id}" title={i18n(currentTransaction.labelPersonalized, item.user)}>
        {@html icon(currentTransaction.icon)}
      </div>
    {/if}
    {#if mainUserIsOwner}
      <div class="visibility {visibilitySummary}" title={i18n(getVisibilitySummaryLabel(visibility))}>
        {@html icon(visibilitySummaryData.icon)}
      </div>
    {/if}
  </div>
</div>

<ItemShowModal bind:item bind:showItemModal />

<style lang="scss">
  @import "#general/scss/utils";

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
  .removed-from-shelf{
    @include shy(0.5);
  }
  .middle{
    flex: 1;
    align-self: stretch;
    @include display-flex(row, center);
    :global(.image-div){
      flex: 0 0 3em;
      align-self: stretch;
      margin-inline-end: 0.5em;
      max-height: $item-row-height-base;
    }
  }
  .title{
    line-height: 1.1rem;
    max-height: 2.2rem;
    overflow: hidden;
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
  .shelves-dots{
    @include display-flex(row);
    margin: 0 0.4em;
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
    flex: 1 0 0;
    align-self: stretch;
    overflow: hidden;
    margin-inline-end: 0.5em;
    min-height: 3rem;
  }
  $user-horizontal-padding: 0.2em;
  .user{
    @include bg-hover(white, 5%);
    align-self: stretch;
    margin: 0.2em 0;
    padding: 0 0.2em;
    @include display-flex(row, center, center);
  }
  .username{
    margin-inline-end: 0.5em;
    @include serif;
  }

  /* Smaller screens */
  @media screen and (max-width: $smaller-screen){
    .username{
      display: none;
    }
  }

  /* Small screens */
  @media screen and (max-width: $smaller-screen){
    .item-row{
      align-self: stretch;
      min-height: $item-row-height-base;
    }
    .show-item{
      align-self: stretch;
    }
    .info{
      text-align: start;
      padding: 0 0.5em;
      max-width: 60vw;
    }
    .details{
      max-height: 3em;
      margin: 0.5em;
    }
    .shelves-dots{
      @include display-flex(column, flex-end, center, wrap-reverse);
      height: 4.5em;
    }
    .modes{
      margin-inline-end: 0.2em;
      flex-direction: column-reverse;
      > div{
        margin: 0.1em 0;
      }
    }
    .transaction, .visibility{
      &:first-child{
        @include radius-top;
        margin-block-start: 0.2em;
      }
      &:last-child{
        @include radius-bottom;
        margin-block-end: 0.2em;
      }
    }
    .user{
      margin-inline-end: 0.5em;
    }
  }

  /* Large screens */
  @media screen and (min-width: $smaller-screen){
    .item-row{
      height: $item-row-height-base;
      overflow: hidden;
    }
    .info{
      flex: 1 1 0;
      text-align: start;
      min-width: 40%;
      max-width: 30em;
    }
    .details{
      max-height: 3em;
      margin: 0 0.5em;
      flex: 1 1 auto;
    }
    $images-right-margin: 0.5em;
    .transaction, .visibility, .user{
      margin-inline-end: $images-right-margin;
    }
    .user{
      margin-inline-end: calc($images-right-margin - $user-horizontal-padding);
    }
    .transaction, .visibility{
      margin-inline-start: 0.2em;
      @include radius;
    }
  }
</style>
