<script>
  import { i18n } from '#user/lib/i18n'
  import { isNonEmptyArray } from '#lib/boolean_tests'
  import { isOpenedOutside } from '#lib/utils'
  import { timeClaim } from '#entities/components/lib/claims_helpers'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import Link from '#lib/components/link.svelte'
  import getBestLangValue from '#entities/lib/get_best_lang_value'

  export let entityData

  const { labels, claims, uri, image } = entityData
  const label = getBestLangValue(app.user.lang, null, labels).value

  const formatYearClaim = dateProp => {
    const values = claims[dateProp]
    return isNonEmptyArray(values) ? values.map(formatTime) : ''
  }
  const formatTime = value => timeClaim({ value, format: 'year' })
  const url = `/entity/${uri}`

  const showLink = e => {
    e.stopPropagation()
    if (!isOpenedOutside(e)) {
      app.navigateAndLoad(url)
      e.preventDefault()
    }
  }
  const birthOrDeathDates = claims['wdt:P569'] || claims['wdt:P570']
</script>
<div
  class="author-el"
  on:click={showLink}
>
  {#if image.url}
    <img src={imgSrc(image.url, 56)} alt={i18n('author picture')}>
  {/if}
  <div class="author-info">
    {#if label}
      <div class="author-line">
        <div class="author-label">
          <Link
            {url}
            text={label}
          />
        </div>
      </div>
    {/if}
    {#if birthOrDeathDates}
      <span title={i18n('wdt:P569')}>
        {formatYearClaim('wdt:P569')}
      </span>
       -
      <span title={i18n('wdt:P570')}>
        {formatYearClaim('wdt:P570')}
      </span>
    {/if}
  </div>
</div>
<style lang="scss">
  @import '#general/scss/utils';
  .author-el{
    @include display-flex(row, center, flex-start);
    background-color: $off-white;
    min-height: 3.5em;
    margin-bottom: 0.5em;
    &:hover{
      opacity: 0.8;
      cursor:pointer;
    }
  }
  .author-info{
    padding: 0 1em;
  }
  .author-line{
    @include display-flex(row, center, flex-start, wrap);
    margin-right: 0.3em;
  }
  .author-label{
    font-weight: bold;
    margin-right: 0.3em;
    max-width: 15em;
  }
</style>
