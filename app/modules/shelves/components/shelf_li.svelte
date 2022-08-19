<script>
  import { i18n } from '#user/lib/i18n'
  import { icon, isOpenedOutside } from '#lib/utils'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import { serializeShelf } from '#shelves/lib/shelves'
  import Shelf from '#shelves/models/shelf'

  export let shelf

  const { name, description } = shelf
  const { pathname, picture, iconData, iconLabel } = serializeShelf(shelf)

  function onClick (e) {
    if (isOpenedOutside(e)) return
    const model = new Shelf(shelf)
    app.vent.trigger('inventory:select', 'shelf', model)
    e.preventDefault()
  }
</script>

<li>
  <a
    href={pathname}
    on:click={onClick}
    class="selectShelf shelf-row"
    title="{name}{description ? ` - ${description}` : ''}"
  >
    <div class="shelf-left">
      <div class="picture" style="background-image: url({imgSrc(picture, 48)})"></div>
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
          title="{i18n(iconLabel)}"
          >
          {@html icon(iconData.icon)}
        </span>
      {/if}
    </div>
  </a>
</li>

<style lang="scss">
  @import '#general/scss/utils';
  .shelf-row{
    height: 3em;
    @include display-flex(row, center, space-between);
    cursor: pointer;
    height: 3em;
    margin: 0.1em 0;
    border-top: 1px solid $off-white;
    @include bg-hover($light-grey, 5%);
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
  .picture{
    min-width: 3em;
    height: 3em;
    @include radius;
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
