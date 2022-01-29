<script>
  import { I18n } from '#user/lib/i18n'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import { getColorSquareDataUri } from '#lib/images'

  export let shelf
  let checked = false
  const shelfColor = getColorSquareDataUri(shelf.color)
  $: shelf.checked = checked
</script>
<div class="shelf" on:click="{() => checked = !checked}">
  <div class="checkbox">
    <input type="checkbox" bind:checked name="{I18n('select_shelf')}">
  </div>
  <div class="shelfList">
    <img class="shelfPicture" src="{imgSrc(shelfColor)}" alt='{shelf.name}'>
    <div class="shelf-text">
      <div class="name">{shelf.name}</div>
      <div class="description">{shelf.description}</div>
    </div>
  </div>
</div>

<style lang="scss">
  @import 'app/modules/general/scss/utils';
  .shelf{
    cursor: pointer;
    @include bg-hover($off-white, 5%);
    @include display-flex(row, center, flex-start);
  }
  .checkbox{
    margin: 0.5em;
  }
  .shelfPicture{
    width: 48px;
  };
  .shelfList{
    @include display-flex(row, center, flex-start);
  }
</style>
