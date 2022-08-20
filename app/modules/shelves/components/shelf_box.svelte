<script>
  import { i18n, I18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import { serializeShelf } from '#shelves/lib/shelves'

  export let shelf, withoutShelf

  let name, description, pathname, picture, iconData, iconLabel, title, isEditable, itemsCount

  if (withoutShelf) {
    name = title = i18n('Items without shelf')
    description = ''
    pathname = '/shelves/without'
  } else {
    ;({ name, description } = shelf)
    ;({ pathname, picture, iconData, iconLabel, isEditable } = serializeShelf(shelf))
    title = `${name}${description ? ` - ${description}` : ''}`
  }

  const showShelfEditor = () => app.execute('show:shelf:editor', shelf)
  const addItems = () => app.execute('add:items:to:shelf', shelf)
  const closeShelf = () => app.vent.trigger('close:shelf')
</script>

<div class="shelf-box">
  <div class="header">
    {#if withoutShelf}
      <div class="without-shelf-picture">{@html icon('question')}</div>
    {:else}
      <div class="picture" style="background-image: url({imgSrc(picture, 160)})"></div>
    {/if}
    <button
      class="close-shelf-small close-button"
      title={I18n('unselect shelf')}
      on:click={closeShelf}
      >
      {@html icon('close')}
    </button>
  </div>
  <div class="info-box">
    <div>
      <h3 class="name">{name}</h3>
      {#if shelf}
        <ul class="data">
          {#if itemsCount}
            <li>
              <span>{@html icon('book')}{i18n('books')}</span>
              <span class="count">{itemsCount}</span>
            </li>
          {/if}
          <li id='listing' title={i18n('visible by')}>
            {@html icon(iconData.icon)} {i18n(iconLabel)}
          </li>
        </ul>
      {/if}
      <p class="description">{description}</p>
    </div>
    <div class="actions">
      <button
        class="close-shelf close-button"
        title={I18n('unselect shelf')}
        on:click={closeShelf}
        >{@html icon('close')}</button>
      <div class="buttons">
        {#if isEditable}
          <button
            class="show-shelf-edit tiny-button light-blue"
            on:click={showShelfEditor}
            >
            {@html icon('pencil')}
            {I18n('edit shelf')}
          </button>
          <button
            class="tiny-button light-blue"
            on:click={addItems}
            title={I18n('add books to this shelf')}
            >
            {@html icon('plus')} {I18n('add books')}
          </button>
        {/if}
      </div>
    </div>
  </div>
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .shelf-box{
    margin: 0.5em 0 0 0;
    @include display-flex(row);
  }
  .picture{
    // TODO: shelf picture
    width: 10em;
    height: 10em;
  }
  .info-box{
    flex: 1;
    padding: 1em;
    @include display-flex(row, top, space-between);
    .name, .description{
      // make button unbreakable
      flex: 1 0 0;
    }
  }
  .actions{
    @include display-flex(column, flex-end);
  }
  .buttons{
    margin-top: 0.5em;
    @include display-flex(column, stretch, center);
    > button{
      @include display-flex(row, center, space-between);
      margin-bottom: 0.5em;
      line-height: 1.6rem;
      min-width: 10em;
    }
  }
  .show-shelf-edit{
    margin-left: auto;
  }
  .data{
    @include display-flex(row, flex-start);
    color: #666;
    margin-bottom: 0.5em;
    li{
      margin-right: 1em;
    }
  }
  .count{
    padding-left: 0.5em;
  }
  .close-shelf-small{
    display: none;
  }
  .close-button{
    font-size: 1.5rem;
    @include text-hover($grey, $dark-grey);
  }
  .without-shelf-picture{
    @include display-flex(row, center, center);
    font-size: 1.5rem;
    height: 3em;
    width: 3em;
    color: $grey;
  }
  /*Smaller screens*/
  @media screen and (max-width: $smaller-screen) {
    .shelf-box{
      @include display-flex(column, center, center);
    }
    .header{
      @include display-flex(row, top, center);
    }
    .picture{
      // TODO: shelf picture
      width: 3em;
      height: 3em;
      margin-top: 0.5em
    }
    .close-shelf-small{
      padding-top: 0.5em;
      position: absolute;
      right: 0.3em;
      display: block;
    }
    .name, .description{
      text-align: center;
    }
    .info-box{
      @include display-flex(column, center, center);
      padding: 0;
      margin-bottom: 0.7em;
    }
    .close-shelf{
      display: none;
    }
    .data{
      @include display-flex(column, center, center);
      li{
        margin: 0.2em 0;
      }
    }
  }
</style>
