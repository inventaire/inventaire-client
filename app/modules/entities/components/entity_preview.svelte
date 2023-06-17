<script>
  import { timeClaim } from '#entities/components/lib/claims_helpers'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import { loadInternalLink } from '#lib/utils'

  export let entity, large = false

  const { claims = {} } = entity

  const yearClaim = prop => {
    if (claims[prop]?.[0]) {
      return timeClaim({ value: claims[prop][0], format: 'year' })
    }
  }
  const yearClaims = (startProp, endProp) => {
    const startValue = yearClaim(startProp)
    const endValue = yearClaim(endProp)
    if (startValue || endValue) return `${startValue || ''} - ${endValue || ''}`
    else return ''
  }
</script>

<a class:large href={entity.pathname} on:click={loadInternalLink}>
  {#if entity.image.url}
    <div class="image-wrapper">
      <img src={imgSrc(entity.image.url, 64)} alt={entity.label} loading="lazy" />
    </div>
  {/if}
  <div class="info">
    <p class="label">
      {entity.label}
      <span class="date">
        {#if entity.type === 'human'}
          {yearClaims('wdt:P569', 'wdt:P570')}
        {:else if entity.type === 'publisher'}
          {yearClaims('wdt:P571', 'wdt:P576')}
        {:else}
          {yearClaim('wdt:P577') || ''}
        {/if}
      </span>
    </p>
    <p class="description">
      {entity.description || ''}
    </p>
    <p class="uri">{entity.uri}</p>
  </div>
</a>

<style lang="scss">
  @import "#general/scss/utils";
  a{
    display: flex;
    flex-direction: row;
    align-items: center;
    justify-content: flex-start;
    background-color: white;
    transition: background-color 0.3s ease;
    border-radius: 3px;
    padding: 0.2em;
    &:hover{
      background-color: $off-white;
    }
  }
  .large{
    padding: 0 0.5em;
  }
  .image-wrapper{
    max-width: 4em;
    margin-right: 0.2em;
  }
  .label{
    font-weight: bold;
    line-height: 1.2rem;
  }
  .info{
    flex: 1 0 0;
  }
  .date{
    color: $grey;
    font-weight: normal;
    margin: 0 0.3em;
  }
</style>
