<script>
  import { i18n } from '#user/lib/i18n'
  import { icon } from '#lib/icons'
</script>

<div class="transactions-welcome">
  <div class="inner">
    {@html icon('exchange')}
    <h2>{i18n('exchanges_manager_welcome_title')}</h2>
    <p>{@html i18n('exchanges_manager_welcome_text')}</p>
  </div>
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .transactions-welcome{
    @include display-flex(column, center, center);
    text-align: center;
    :global(.fa){
      font-size: 2rem;
    }
  }
  .inner{
    max-width: 40rem;
    background-color: $contrast;
    padding: 2rem;
    @include radius;
    @include shy-border;
  }
  p{
    color: $grey;
  }
  /* Large screens */
  @media screen and (min-width: $small-screen){
    .transactions-welcome{
      height: 30rem;
      max-height: 50vh;
    }
  }
</style>
