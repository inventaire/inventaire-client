<script>
  import { i18n, I18n } from '#user/lib/i18n'
  import Link from '#lib/components/link.svelte'
</script>

<div class="inventory-welcome">
  <h3>{I18n('welcome to your inventory!')}</h3>
  <div class="ideas">
    <Link
      icon="plus"
      url="/add"
      text={I18n('add books')}
      title={i18n('title_add_layout')}
      tinyButton={true}
      classNames="light-blue"
    />
  </div>
</div>

<style lang="scss">
  @import "#general/scss/utils";

  .inventory-welcome{
    flex: 1 1 auto;
    @include display-flex(column, center, center);
    text-align: center;
    /* Large screens */
    @media screen and (min-width: $small-screen){
      min-height: 50vh;
    }
  }
  .ideas{
    margin: 1em;
  }
</style>
