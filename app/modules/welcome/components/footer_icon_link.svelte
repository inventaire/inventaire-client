<script>
  import { icon as iconFn } from '#lib/handlebars_helpers/icons'

  export let url
  export let icon
  export let text
</script>

<a
  href={url}
  target="_blank"
  rel="noreferrer"
>
  {@html iconFn(icon)}
  <span class="text">{text}</span>
</a>

<style lang="scss">
  @import "#general/scss/utils";
  a{
    @include display-flex(column, center, center);
    margin-top: 1em;
    margin-bottom: 1em;
    &:hover{
      text-decoration: none;
      :global(.fa), span{
        color: $secondary-color;
      }
    }
    :global(.fa){
      margin: 0;
      padding: 0;
      font-size: 2.5em;
    }
    span{
      padding: 0;
      font-weight: bold;
    }
    :global(.fa), span{
      color: white;
    }
    // The following adjustements are coupled to a list of 8 icons
    flex: 1 0 10em;
    /* Medium screens */
    @media screen and (max-width: 82em){
      // Do not let a lonely icon on a line
      flex: 1 0 25%;
    }
    /* Small screens */
    @media screen and (max-width: 42em){
      flex: 1 0 10em;
    }
  }
</style>
