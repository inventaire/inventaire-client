<script>
  import { imgSrc } from 'lib/handlebars_helpers/images'

  export let entity
</script>

<a class="showEntity" href="{entity.pathname}">
  {#if entity.image.url}
    <div class="image-wrapper">
      <img src="{imgSrc(entity.image.url, 64)}" alt="{entity.label}" >
    </div>
  {/if}
  <div>
    <p class="label">{entity.label}</p>
    <p class="description">{entity.description || ''}</p>
    <p class="uri">{entity.uri}</p>
  </div>
</a>

<style>
  .showEntity{
    display: flex;
    flex-direction: row;
    align-items: center;
    justify-content: center;
    transition: background-color 0.3s ease;
    border-radius: 3px;
    padding: 0 0.5em;
  }
  .showEntity:hover{
    background-color: white;
  }
  .image-wrapper{
    max-width: 4em;
    margin-right: 0.2em;
  }
  .label{
    font-weight: bold;
  }
</style>
