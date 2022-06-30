<script>
  import Link from '#lib/components/link.svelte'
  import { i18n } from '#user/lib/i18n'
  import getBestLangValue from '#entities/lib/get_best_lang_value'
  import { propertiesType, formatClaimValue } from '#entities/components/lib/claims_helpers'

  export let prop,
    values,
    omitLabel = false,
    entitiesByUris

  const propType = propertiesType[prop]

  let linkTitle = uri => `${i18n(prop)}: ${getBestLabel(entitiesByUris[uri])}`

  const getBestLabel = entity => getBestLangValue(app.user.lang, null, entity.labels).value
</script>
<div class="claim">
  {#if !omitLabel}
    <span class='property'>
      {i18n(prop)}:&nbsp;
    </span>
  {/if}
  <div class="values">
    {#each values as value}
      <span>
        {#if entitiesByUris[value]}
          <Link
            url={`/entity/${value}`}
            text={getBestLabel(entitiesByUris[value])}
            dark={true}
            title={linkTitle(value)}
          />
        {:else if propType === 'urlClaim'}
          <Link
            url={value}
            text={formatClaimValue({ prop, value })}
            dark={true}
          />
        {:else}
          {formatClaimValue({ prop, value })}
        {/if}
      </span>
    {/each}
  </div>
</div>
<style lang="scss">
  @import '#general/scss/utils';
  .claim{
    @include display-flex(row, center, flex-start, wrap);
  }
  .values{
    padding-left: 0.2em;
    @include display-flex(row, center, flex-start, wrap);
    :not(:last-child):after{
      margin-right: 0.2em;
      content: ',';
    }
  }
  .property{
    color: $grey;
  }
</style>
