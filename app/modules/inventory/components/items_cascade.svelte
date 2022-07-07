<script>
  import ItemCard from '#inventory/components/item_card.svelte'
  export let items
</script>

<ul class="items-cascade">
  {#each items as item}
    <ItemCard {item} />
  {/each}
</ul>

<style lang="scss">
  @import '#general/scss/utils';

  $itemCardBaseWidth: 230px;
  $itemsCasccadeMulticolumnsThreshold: $itemCardBaseWidth * 2 + 50px;

  .items-cascade{
    // required to avoid itemsLists to overlapse when empty
    // !important to override Masonry's style="height:0px"
    // ex: entity_show
    min-height: 10em !important;
    /*Small screens*/
    @media screen and (max-width: $itemsCasccadeMulticolumnsThreshold) {
      @include display-flex(column, center, center);
    }

    /*Large screens MASONRY */
    @media screen and (min-width: $itemsCasccadeMulticolumnsThreshold) {
      // required by Masonry to center elements in conjunction with isFitWidth: true
      // See https://desandro.github.io/masonry/demos/centered.html
      margin: 0 auto;
    }
    // itemCard positioning item-settings
    // for itemCard internal, see item_card
    :global(.item-card){
      width: $itemCardBaseWidth;
      margin: 5px;
      float: left;
      /*Small screens*/
      @media screen and (max-width: $itemsCasccadeMulticolumnsThreshold) {
          width: 94vw;
          max-width: 300px;
        }

      /*Large screens*/
      @media screen and (min-width: $itemsCasccadeMulticolumnsThreshold) {
      }
    }
  }
</style>
