<script lang="ts">
  import { imgSrc } from '#app/lib/image_source'
  import { loadInternalLink } from '#app/lib/utils'
  import { formatYearClaim } from '#entities/components/lib/claims_helpers'
  import { getBestLangValue } from '#entities/lib/get_best_lang_value'
  import { getCurrentLang, i18n } from '#user/lib/i18n'

  export let entity, claimValue, hasManyClaimValues

  let labels, claims = {}, uri, image
  let url, label
  $: {
    if (entity) {
      ({ labels, claims, uri, image } = entity)
    }
    if (uri) {
      url = `/entity/${uri}`
      label = getBestLangValue(getCurrentLang(), null, labels).value
    } else {
      label = claimValue
      url = `/search?q=!a ${label}`
    }
  }

  $: birthOrDeathDates = claims['wdt:P569']?.[0] || claims['wdt:P570']?.[0]
</script>

<a
  href={url}
  title={label}
  on:click={loadInternalLink}
  class:hasManyClaimValues
>
  {#if image?.url}
    <img src={imgSrc(image.url, 56)} alt={i18n('author picture')} loading="lazy" />
  {/if}
  <div class="author-info">
    <p class="author-label">{label}</p>
    {#if birthOrDeathDates}
      <span title={i18n('wdt:P569')}>
        {formatYearClaim('wdt:P569', claims)}
      </span>
      -
      <span title={i18n('wdt:P570')}>
        {formatYearClaim('wdt:P570', claims)}
      </span>
    {/if}
  </div>
</a>

<style lang="scss">
  @import "#general/scss/utils";
  a{
    @include display-flex(row, center, flex-start);
    background-color: $off-white;
    min-block-size: 4em;
    margin-inline-end: 0.5em;
    margin-block-end: 0.5em;
    &:hover{
      opacity: 0.8;
      cursor: pointer;
    }
  }
  .hasManyClaimValues{
    inline-size: 15em;
  }
  .author-info{
    padding: 0 1em;
  }
  .author-label{
    font-weight: bold;
    margin-inline-end: 0.3em;
    max-inline-size: 15em;
  }
</style>
