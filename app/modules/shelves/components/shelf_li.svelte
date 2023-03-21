<script>
  import { i18n } from '#user/lib/i18n'
  import { icon, isOpenedOutside } from '#lib/utils'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import { serializeShelfData } from './lib/shelves'
  import { createEventDispatcher } from 'svelte'
  import { onChange } from '#lib/svelte/svelte'

  export let shelf, withoutShelf

  let name, description, pathname, title, picture, iconData, iconLabel
  function refreshData () {
    ;({ name, description, pathname, title, picture, iconData, iconLabel } = serializeShelfData(shelf, withoutShelf))
  }
  $: onChange(shelf, refreshData)

  const dispatch = createEventDispatcher()

  function onClick (e) {
    if (isOpenedOutside(e)) return
    if (withoutShelf) {
      dispatch('selectShelf', { shelf: null })
    } else {
      dispatch('selectShelf', { shelf })
    }
    e.preventDefault()
  }
</script>

<li>
  <a
    href={pathname}
    on:click={onClick}
    class="shelf-row"
    class:without-shelf={withoutShelf}
    {title}
  >
    <div class="shelf-left">
      {#if picture}
        <div class="picture" style:background-image="url({imgSrc(picture, 48)})" />
      {:else}
        <div class="without-shelf-picture">...</div>
      {/if}
      <div class="shelf-text">
        <div class="name">{name}</div>
        <div class="description">{description}</div>
      </div>
    </div>
    <div class="shelf-right">
      {#if iconData}
        <span
          class="listing"
          class:private={iconData.id === 'private'}
          class:network={iconData.id === 'network'}
          class:public={iconData.id === 'public'}
          title={i18n(iconLabel)}
        >
          {@html icon(iconData.icon)}
        </span>
      {/if}
    </div>
  </a>
</li>

<style lang="scss">
  @import "#general/scss/utils";
  .shelf-row{
    @include display-flex(row, center, space-between);
    cursor: pointer;
    height: 3em;
    margin: 0.1em 0;
    border-top: 1px solid $off-white;
    @include bg-hover($light-grey, 5%);
  }
  .without-shelf{
    @include shy(0.8);
  }
  .shelf-left{
    @include display-flex(row, center);
    overflow: hidden;
    line-height: 1.2em;
  }
  .shelf-right{
    @include display-flex(row);
    padding-right: 1em;
  }
  .shelf-text{
    max-height: 3em;
    line-height: 1.4em;
    overflow: hidden;
    padding: 0.2em 0.4em;
    margin-right: 1em;
  }
  .picture, .without-shelf-picture{
    min-width: 3em;
    height: 3em;
    @include radius;
  }
  .without-shelf-picture{
    @include display-flex(row, center, center);
  }
  .description{
    color: $grey;
    max-height: 1.4em;
    overflow: hidden;
  }
  .listing{
    @include radius;
    height: 2em;
    width: 2em;
    @include display-flex(row, center, center);
    &.private{
      background-color: $private-color;
      color: white;
    }
    &.network{
      background-color: $network-color;
      color: white;
    }
    &.public{
      background-color: $public-color;
    }
  }
</style>
