<script>
  import { imgSrc } from '#lib/handlebars_helpers/images'

  export let entity, large = false
</script>

<a class="showEntity" class:large href="{entity.pathname}">
  {#if entity.image.url}
    <div class="image-wrapper">
      <img src="{imgSrc(entity.image.url, 64)}" alt="{entity.label}" >
    </div>
  {/if}
  <div class="info">
    <p class="label">{entity.label}</p>
    <p class="description">{entity.description || ''}</p>
    <p class="uri">{entity.uri}</p>
  </div>
</a>

<style lang="scss">
  @import '#general/scss/utils';

  .showEntity{
    display: flex;
    flex-direction: row;
    align-items: center;
    justify-content: flex-start;
    background-color: white;
    transition: background-color 0.3s ease;
    border-radius: 3px;
  }
  .large{
    padding: 0 0.5em;
  }
  .showEntity:hover{
    background-color: $off-white;
  }
  .image-wrapper{
    max-width: 4em;
    margin-right: 0.2em;
  }
  .label{
    font-weight: bold;
  }
  .info{
    flex: 1 0 0;
  }
</style>
