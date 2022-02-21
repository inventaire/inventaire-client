<script>
  import { I18n } from '#user/lib/i18n'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import { getColorSquareDataUri, getColorHexCodeFromModelId } from '#lib/images'

  export let shelf
  let checked = false
  const shelfColor = getColorSquareDataUri(shelf.color || getColorHexCodeFromModelId(shelf._id))
  $: shelf.checked = checked
</script>
<div class="shelf" on:click="{() => checked = !checked}">
  <input class="checkbox" type="checkbox" bind:checked name="{I18n('select_shelf')}">
  <div class="shelf-list">
    <img class="shelf-picture" src="{imgSrc(shelfColor)}" alt='{shelf.name}'>
    <div class="shelf-text">
      <div>{shelf.name}</div>
      <div>{shelf.description}</div>
    </div>
  </div>
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .shelf{
    @include bg-hover($off-white, 5%);
    @include display-flex(row, center, flex-start);
    @include radius;
    cursor: pointer;
    border: solid 1px #ccc;
    margin-bottom: 0.1em;
  }
  .checkbox{
    margin: 0.5em;
  }
  .shelf-picture{
    width: 48px;
  };
  .shelf-list{
    @include display-flex(row, center, flex-start);
  }
  .shelf-text{
    margin: 0 0.5em;
  }
</style>
