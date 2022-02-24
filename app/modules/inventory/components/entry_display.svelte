<script>
  import { I18n } from '#user/lib/i18n'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import getOriginalLang from '#entities/lib/get_original_lang'
  import getBestLangValue from '#entities/lib/get_best_lang_value'
  import EntityLogo from '#inventory/components/entity_source_logo.svelte'
  import EntityValueInput from '#inventory/components/entity_value_input.svelte'
  import { isNonEmptyArray } from '#lib/boolean_tests'

  export let isbnData
  export let edition
  export let works
  export let authors
  export let customWorkTitle
  export let customAuthorsNames
  export let withEditor = false

  const rawIsbn = isbnData?.rawIsbn
  let firstAuthorName, work, editionLang
  if (works && works.length > 0) work = works[0]

  if (edition) {
    editionLang = getOriginalLang(edition.claims)
  } else {
    editionLang = 'en'
  }

  if (isNonEmptyArray(customAuthorsNames)) {
    firstAuthorName = customAuthorsNames[0]
  }

  const findBestLang = objectWithLabels => {
    if (!objectWithLabels || !objectWithLabels.labels) return
    return getBestLangValue(editionLang, null, objectWithLabels.labels).value
  }

  $: {
    if (isNonEmptyArray(customAuthorsNames)) {
      customAuthorsNames[0] = firstAuthorName
    }
  }
</script>
<div class="entry-display">
  <div class="edition-cover">
    {#if edition?.image?.url}
      <img src="{imgSrc(edition.image.url, 80)}" alt='{findBestLang(work, editionLang)} cover'>
    {/if}
  </div>
  <div class="text-wrapper">
    <div class="work">
      {#if work}
        <span class="label">{I18n('title')}:</span>
          <!-- Necessary span to look like <sup> (exponent) element -->
        <span>
          {findBestLang(work, editionLang)}
          <EntityLogo entity="{work}"/>
        </span>
      {:else}
        {#if withEditor}
          <EntityValueInput type='work' bind:inputName={customWorkTitle}/>
        {/if}
      {/if}
    </div>
    <div class="authors">
      {#if authors && authors.length > 0}
        <span class="label">{I18n('authors')}:</span>
        {#each authors as author, id}
          <!-- Necessary span to look like <sup> (exponent) element -->
          <span>
            {findBestLang(author)}
            <EntityLogo entity="{author}"/>
            <!-- prefer this to CSS :last-child, to be able to have a space after the comma -->
            {#if id !== authors.length - 1},&nbsp;{/if}
          </span>
        {/each}
      {:else}
        <!-- Do not display editor if work exists, as it may be a book without author -->
        <!-- always displaying editor might overcrowd the visual, known case: /add/import -->
        <!-- Do not display editor if several authors -->
        <!-- as creating multiple authors from user input overcrowds the visual too-->
        {#if withEditor && !work && isNonEmptyArray(customAuthorsNames)}
          <EntityValueInput type='author' bind:inputName={firstAuthorName}/>
        {:else}
          {#if isNonEmptyArray(customAuthorsNames)}
            <span class="label">{I18n('authors')}:</span>
            {#each customAuthorsNames as author, id}
              <span>
                {author}
              </span>
            {/each}
          {/if}
        {/if}
      {/if}
    </div>
    <div class="isbn">
      {#if rawIsbn}
        <span class="label">ISBN:</span>
        {rawIsbn}
        {#if edition}
          <EntityLogo entity="{edition}"/>
        {/if}
      {/if}
    </div>
  </div>
</div>
<style lang="scss">
  @import '#general/scss/utils';
  .entry-display{
    margin-right: 1em;
    width: 100%;
    @include display-flex(row, center, space-between);
    .edition-cover{
      margin-right: 1em;
      min-width: 4em;
    }
  }
  .text-wrapper{
    @include display-flex(column);
    width: 100%;
    padding: 0.2em 0;
    line-height: 1.5em;
  }
  .label{
    display: inline;
    color: $grey;
    font-size: 90%;
    margin-right: 0.5em;
  }
</style>
