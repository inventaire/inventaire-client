<script>
  import { createEventDispatcher } from 'svelte'
  import { getEntityImagePath } from '#entities/lib/entities'
  import { entityTypeNameByType } from '#entities/lib/types/entities_types'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import { I18n } from '#user/lib/i18n'

  export let suggestion, highlight, displaySuggestionType = false, scrollableElement
  let element
  const { uri, type, label, description, image: images } = suggestion
  const dispatch = createEventDispatcher()
  const typeName = entityTypeNameByType[type]

  const image = images?.[0]
  const imageUrl = image ? getEntityImagePath(image) : null

  $: {
    if (element && highlight && scrollableElement) {
      scrollableElement.scroll({
        top: Math.max(0, (element.offsetTop - 20)),
        behavior: 'smooth',
      })
    }
  }
</script>

<li bind:this={element}>
  <button
    on:click|stopPropagation={() => dispatch('select')}
    class:highlight
  >
    <div
      class="image"
      style:background-image={imageUrl ? `url(${imgSrc(imageUrl, 90)})` : ''}
    />
    <div class="right">
      <div class="top">
        <span class="label">{label}</span>
        <a
          class="uri"
          href="/entity/{uri}"
          target="_blank"
          rel="noreferrer"
          on:click|stopPropagation>{uri}</a>
      </div>
      <div class="bottom">
        {#if description}<span class="description">{description}</span>{/if}
        {#if displaySuggestionType}<span class="type">{I18n(typeName)}</span>{/if}
      </div>
    </div>
  </button>
</li>

<style lang="scss">
  @import "#general/scss/utils";
  li{
    margin: 0;
  }
  button{
    @include bg-hover(white);
    inline-size: 100%;
    margin: 0;
    padding: 0;
    @include display-flex(row, stretch);
  }
  .highlight{
    background-color: #ddd;
  }
  .image{
    margin-inline-end: 0.3em;
    inline-size: 48px;
    block-size: 48px;
    background-size: cover;
    background-position: center center;
  }
  .right{
    padding: 0.5em;
    flex: 1 0 0;
  }
  .top{
    @include display-flex(row, center, space-between);
  }
  .bottom{
    @include display-flex(row, center, space-between);
  }
  .label{
    font-weight: bold;
    text-align: start;
    margin-inline-end: auto;
  }
  .description, .uri{
    font-weight: normal;
  }
  .type, .description{
    text-align: start;
  }
  .description{
    color: $grey;
    display: block;
  }
  .type{
    color: $grey;
    text-align: end;
    font-size: 0.9rem;
  }
  .uri{
    white-space: nowrap;
    align-self: flex-start;
  }
</style>
