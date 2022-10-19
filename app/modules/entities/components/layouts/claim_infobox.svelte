<script>
  import Link from '#lib/components/link.svelte'
  import { i18n } from '#user/lib/i18n'
  import getBestLangValue from '#entities/lib/get_best_lang_value'
  import { propertiesType, formatClaimValue, buildPathname } from '#entities/components/lib/claims_helpers'

  export let prop,
    values,
    omitLabel = false,
    entitiesByUris

  const propType = propertiesType[prop]
  const lastValueIndex = values.length - 1

  let linkTitle = uri => `${i18n(prop)}: ${getBestLabel(entitiesByUris[uri])}`

  const getBestLabel = entity => getBestLangValue(app.user.lang, null, entity.labels).value
</script>
{#if values}
  <div class="claim">
    {#if !omitLabel}
      <span class='property'>
        {i18n(prop)}:&nbsp;
      </span>
    {/if}
    <span class="values">
      {#each values as value, i}
        <!-- This peculiar formatting is used to avoid undesired spaces to be inserted
             See https://github.com/sveltejs/svelte/issues/3080 -->
        {#if entitiesByUris[value]}
        <Link
            url={buildPathname(entitiesByUris[value], prop)}
            text={getBestLabel(entitiesByUris[value])}
            dark={true}
            title={linkTitle(value)}
          />{:else if propType === 'urlClaim'}<Link
            url={value}
            text={formatClaimValue({ prop, value })}
            dark={true}
          />{:else}{formatClaimValue({ prop, value })}{/if}{#if i !== lastValueIndex},{/if}
      {/each}
    </span>
  </div>
{/if}
<style lang="scss">
  @import '#general/scss/utils';
  .property{
    color: $grey;
  }
</style>
