<script>
  import { i18n } from '#user/lib/i18n'
  import getBestLangValue from '#entities/lib/get_best_lang_value'
  import { isEntityUri } from '#lib/boolean_tests'
  import { propertiesType, formatClaimValue, buildPathname } from '#entities/components/lib/claims_helpers'
  import Link from '#lib/components/link.svelte'

  export let value, prop, entity

  const propType = propertiesType[prop]

  let linkTitle = uri => `${i18n(prop)}: ${getBestLabel(entity)}`

  const getBestLabel = entity => getBestLangValue(app.user.lang, null, entity.labels).value
</script>
<!-- This peculiar formatting is used to avoid undesired spaces to be inserted
     See https://github.com/sveltejs/svelte/issues/3080 -->
  {#if entity}
  <Link
      url={buildPathname(entity, prop)}
      text={getBestLabel(entity)}
      dark={true}
      title={linkTitle(value)}
    />{:else if propType === 'urlClaim'}<Link
      url={value}
      text={formatClaimValue({ prop, value })}
      dark={true}
    />{:else}{#if !isEntityUri(value)}{formatClaimValue({ prop, value })}{/if}{/if}
<style lang="scss">
  @import '#general/scss/utils';
</style>
