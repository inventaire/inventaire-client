<script>
  import { i18n } from '#user/lib/i18n'
  import { icon, loadInternalLink } from '#lib/utils'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import { serializeItem } from '#inventory/lib/items'
  import ItemMixedBox from '#inventory/components/item_mixed_box.svelte'
  import ItemUserBox from '#inventory/components/item_user_box.svelte'
  import ItemTransactionBox from '#inventory/components/item_transaction_box.svelte'
  import ItemVisibilityBox from '#inventory/components/item_visibility_box.svelte'
  import ItemRequestBox from '#inventory/components/item_request_box.svelte'
  import Flash from '#lib/components/flash.svelte'

  export let item, showDistance

  const {
    details,
    busy,
  } = item

  const {
    pathname,
    image,
    title,
    subtitle,
    authors,
    series,
    ordinal,
    restricted,
    userReady = true,
  } = serializeItem(item)

  $: isPrivate = item.visibility?.length === 0

  let detailsMore = false
  let flash
</script>

<li class="item-card" class:busy>
  {#if busy}
    <div class="busy-sign" title="{i18n('unavailable')}">
      {@html icon('sign-out')}
    </div>
  {/if}
  <!-- TODO: find a way to share item object with item_show to keep item data in sync -->
  <a class="item-show" href={pathname} on:click={loadInternalLink}>
    <div class="cover">
      {#if image}
        <img src="{imgSrc(image, 300)}" alt="{title}">
      {/if}
    </div>
    <div class="data">
      {#if series}
        <span class="series" title="{i18n('series')}">{series} {#if ordinal}- {ordinal}{/if}</span>
        <hr>
      {/if}
      <h3 class="title">{title}</h3>
      {#if subtitle}<p class="subtitle">{subtitle}</p>{/if}
      {#if authors}
        <hr>
        <span class="authors" title="{i18n('authors')}">{authors}</span>
      {/if}
    </div>
  </a>
  {#if userReady}
    {#if restricted}
      <ItemMixedBox {item} {showDistance} />
    {:else}
      <ItemUserBox user={item.user} />
      <div class="item-card-settings">
        {#if !isPrivate}
          <ItemTransactionBox bind:item bind:flash />
        {/if}
        <ItemVisibilityBox bind:item bind:flash />
      </div>
    {/if}
    {#if details}
      <div class="detailsBox">
        <p class="details wrapped user-content">
          {details}
          {#if detailsMore}
            <a class="itemShow more" href="{pathname}">{i18n('see more')}</a>
          {/if}
        </p>
      </div>
    {/if}
    <ItemRequestBox {item} />
  {/if}
  <Flash state={flash} />
</li>

<style lang="scss">
  @import '#general/scss/utils';
  .item-card{
    @include display-flex(column, stretch, center);
    @include shadow-box;
    @include radius;
    padding: 1em;
    background: #fefefe;
  }
  .busy{
    .item-show{
      @include shy(0.5);
    }
    position: relative;
  }
  .busy-sign{
    opacity: 1;
    z-index: 1;
    @include position(absolute, 0, 0);
    background-color: #222;
    height: 2em;
    width: 2em;
    color: white;
    padding: 0.3em 0.5em 0.5em 0.5em;
    @include radius-diagonal-b;
  }
  .item-show{
    @include display-flex(column, center);
    &:hover, &:focus{
      @include transition(background-color);
      background-color: $light-grey;
    }
  }
  h3.title{
    @include link;
    color: $dark-grey;
  }
  .subtitle{
    font-size: 1rem;
    color: $grey;
  }
  hr{
    margin: 0.2em auto;
    max-width: 1em;
  }
  img:not(.profilePic) {
    max-height: 20em;
    border-bottom: 1px solid #ccc;
    padding-bottom: 15px;
    margin-bottom: 5px;
  }
  .data{
    width: 100%;
    text-align: center;
    font-size: 1.2em;
    max-height: 12em;
    overflow: hidden;
    margin-bottom: 0.5em;
  }
  .title{
    @include serif;
    font-size: 1.2em;
    line-height: 1em;
    margin: 0;
    max-height: 7em;
    overflow: hidden;
    // Avoid hidding letters descender
    padding: 0.2em 0;
  }
  .subtitle, .series, .authors{
    font-size: 0.8em;
    // Required to set line-height
    display: block;
    line-height: 1em;
    color: $grey;
  }
  .item-card-settings{
    @include display-flex(row, stretch, center);
  }
</style>