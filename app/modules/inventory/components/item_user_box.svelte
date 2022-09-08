<script>
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import { loadInternalLink } from '#lib/utils'

  export let user
</script>

<a href={user.pathname} on:click|stopPropagation={loadInternalLink}>
  <img alt="{user.username} avatar" src={imgSrc(user.picture, 48)}>
  <strong class="username">{user.username}</strong>
</a>

<style lang="scss">
  @import '#general/scss/utils';
  a{
    max-height: $user-box-heigth;
    @include bg-hover(white);
    @include display-flex(row, center, flex-start);
    .username{
      margin-left: 0.4em;
    }
  }
  img{
    height: 2.8em;
    background-color: white;
  }
</style>
