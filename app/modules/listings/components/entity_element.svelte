<script>
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import { i18n } from '#user/lib/i18n'

  export let entity

  const { uri, label, description, type, image } = entity

  let altMessage

  if (entity.type === 'edition') {
    altMessage = `${entity.type} cover`
  } else {
    altMessage = `${entity.type} image`
  }
</script>
<a
  href="/entity/{uri}"
  on:click|stopPropagation
  class="entity-element"
>
  {#if image}
    <img
      src={imgSrc(image.url, 80)}
      alt="{i18n(altMessage)} - {label}"
    >
  {/if}
  <div>
    <span class="label">{label}</span>
    <span class="type">{type}</span>
    {#if description}
      <div class="description">{description}</div>
    {/if}
  </div>
</a>

<style lang="scss">
  @import '#general/scss/utils';
  img{
    width: 4em;
    max-height: 7em;
    margin-right: 0.5em;
  }
  .entity-element{
    @include display-flex(row, flex-start, flex-start, wrap);
    flex: 1;
    padding: 0.5em 0;
  }

  .label{
    padding-right: 0.5em;
  }
  .type{
    font-size: 0.9em;
  }
  .top{
  	@include display-flex(row, center, flex-start, wrap);
  }
  .type, .description{
    color: $grey;
    margin-right: 1em;
  }
</style>
