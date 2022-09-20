<script>
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import { loadInternalLink } from '#lib/utils'
  import { i18n } from '#user/lib/i18n'
  import { createEventDispatcher } from 'svelte'

  export let entity, isEditable

  const dispatch = createEventDispatcher()

  const { uri, label, description, type, image } = entity

  let altMessage

  if (entity.type === 'edition') {
    altMessage = `${entity.type} cover`
  } else {
    altMessage = `${entity.type} image`
  }
</script>

<li>
  <a
    href="/entity/{uri}"
    on:click={loadInternalLink}
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
  {#if isEditable}
    <div class="status">
      <button
        class="tiny-button"
        on:click={() => dispatch('removeElement')}
      >
        {i18n('remove')}
      </button>
    </div>
  {/if}
</li>

<style lang="scss">
  @import '#general/scss/utils';
  li{
    @include display-flex(row, center);
    padding: 0 1em;
    width: 100%;
    border-bottom: 1px solid $light-grey;
    &:hover{
      background-color: $off-white;
    }
  }
  img{
    width: 4em;
    max-height: 7em;
    margin-right: 0.5em;
  }
  a{
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
  .type, .description{
    color: $grey;
    margin-right: 1em;
  }
  .status{
    @include display-flex(row, center, center);
    white-space: nowrap;
  }
  /*Very small screens*/
  @media screen and (max-width: $very-small-screen) {
    li{
      @include display-flex(column, flex-start);
    }
  }
</style>
