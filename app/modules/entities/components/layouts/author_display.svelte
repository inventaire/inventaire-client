<script>
  import { isNonEmptyArray } from '#lib/boolean_tests'
  import { i18n } from '#user/lib/i18n'
  import { timeClaim } from '#entities/components/lib/claims_helpers'
  import Link from '#lib/components/link.svelte'
  import getBestLangValue from '#entities/lib/get_best_lang_value'

  export let entityData, authorRole

  const { labels, claims, uri } = entityData
  const label = getBestLangValue(app.user.lang, null, labels).value

  const formatYearClaim = dateProp => {
    const values = claims[dateProp]
    if (isNonEmptyArray(values)) return values.map(formatTime)
  }
  const formatTime = value => timeClaim({ value, format: 'year' })
  const url = `/entity/${uri}`
  const title = `${authorRole} (${formatYearClaim('wdt:P569')}-${formatYearClaim('wdt:P570')})`
</script>
<h4 class="authorLabel {authorRole}">
  {#if label}
    <Link
      {url}
      text={label}
      title={title}
      dark={true}
    />
  {/if}
</h4>
{#if authorRole && (authorRole !== 'author')}
  <span class='author-role'>
    &nbsp;(
      {i18n(authorRole)}
    )
  </span>
{/if}
<style>
  h4 {
    margin-bottom: 0;
  }
</style>