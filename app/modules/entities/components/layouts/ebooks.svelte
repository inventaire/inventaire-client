<script>
  import { formatEbooksClaim } from '#entities/components/lib/claims_helpers'
  import { isNonEmptyArray } from '#lib/boolean_tests'
  import Link from '#lib/components/link.svelte'
  import sitelinks_ from '#lib/wikimedia/sitelinks'
  import { i18n } from '#user/lib/i18n'

  export let entity

  const userLang = app.user.lang
  const { claims } = entity
  let ebooksData = []

  const formatAndAssignEbooks = prop => {
    const valuesData = formatEbooksClaim(claims[prop], prop)
    if (valuesData) ebooksData = [ ...ebooksData, ...valuesData ]
  }

  formatAndAssignEbooks('wdt:P2034')
  formatAndAssignEbooks('wdt:P724')
  formatAndAssignEbooks('wdt:P4258')

  const wikisourceLink = sitelinks_.wikisource(entity.sitelinks, userLang, entity.originalLang)
</script>
{#if isNonEmptyArray(ebooksData)}
  <div class="ebooks">
    <span>{i18n('ebooks')}:</span>
    {#each ebooksData as value}
      <Link
        url={value.url}
        html={value.text}
      />
    {/each}
    {#if wikisourceLink}
      <Link
        url={wikisourceLink.url}
        text={i18n('on Wikisource')}
        icon="wikisource"
      />
    {/if}
  </div>
{/if}
<style lang="scss">
  @import "#general/scss/utils";
  .ebooks{
    @include display-flex(row, center, flex-start, wrap);
    color: $label-grey;
    :global(.icon){
      margin-inline: 0.6em 0.4em;
    }
    :global(a){
      @include link-dark;
    }
  }
</style>
