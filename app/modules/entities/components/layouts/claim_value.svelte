<script lang="ts">
  import { isEntityUri } from '#app/lib/boolean_tests'
  import Link from '#app/lib/components/link.svelte'
  import { propertiesType, formatClaimValue, buildPathname } from '#entities/components/lib/claims_helpers'
  import { getBestLangValue } from '#entities/lib/get_best_lang_value'
  import { i18n } from '#user/lib/i18n'
  import { mainUser } from '#user/lib/main_user'

  export let value, prop, entity

  const propType = propertiesType[prop]

  const getBestLabel = entity => getBestLangValue(mainUser.lang, null, entity.labels).value
</script>
<!-- This peculiar formatting is used to avoid undesired spaces to be inserted
     See https://github.com/sveltejs/svelte/issues/3080 -->
{#if entity}
  <Link
    url={buildPathname(entity, prop)}
    text={getBestLabel(entity)}
    dark={true}
    title={`${i18n(prop)}: ${getBestLabel(entity)}`}
  />{:else if propType === 'urlClaim'}<Link
  url={value}
  text={formatClaimValue({ prop, value })}
  dark={true}
/>{:else}{#if !isEntityUri(value)}{formatClaimValue({ prop, value })}{/if}{/if}
<style lang="scss">
  @import "#general/scss/utils";
</style>
