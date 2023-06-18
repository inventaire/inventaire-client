<script>
  import { I18n } from '#user/lib/i18n'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import { isNonEmptyArray } from '#lib/boolean_tests'
  import getOriginalLang from '#entities/lib/get_original_lang'
  import getBestLangValue from '#entities/lib/get_best_lang_value'
  import EntityLogo from '#inventory/components/entity_source_logo.svelte'
  import EntityResolverInput from '#inventory/components/entity_resolver_input.svelte'

  export let isbnData
  export let edition
  export let work
  export let authors = []
  export let editionTitle
  export let withEditor = false
  const initialWorkUri = work.uri
  const isbn13h = isbnData?.isbn13h
  let editionLang, editableAuthors
  let userSelectedWorkUri, currentEditionLabel

  if (edition) {
    editionLang = getOriginalLang(edition.claims)
  } else {
    editionLang = 'en'
  }

  const findBestLang = objectWithLabels => {
    if (objectWithLabels.label) return objectWithLabels.label
    if (!objectWithLabels || !objectWithLabels.labels) return
    return getBestLangValue(editionLang, null, objectWithLabels.labels).value
  }

  // Removing authors and editionTitle if a work is selected allows to not create entities based on import file strings.
  // To consider: displayed work may already have a description with author name
  $: {
    if (userSelectedWorkUri) {
      authors = []
      editionTitle = null
    }
  }
  // Do not display authors editor if work exists
  // as this only an importer, not an editor of existing entity
  $: editableAuthors = (withEditor && !work.uri)
  // pass on user input to create work and edition when unseccessfull search
  $: editionTitle = currentEditionLabel
</script>

<div class="entry-display">
  <div class="edition-cover">
    {#if edition?.image?.url}
      <img
        src={imgSrc(edition.image.url, 80)}
        alt="" />
    {/if}
  </div>
  <div class="text-wrapper">
    <div class="work">
      {#if initialWorkUri}
        <span class="label">{I18n('title')}:</span>
        <!-- Necessary span to look like <sup> (exponent) element -->
        <span>
          {findBestLang(work, editionLang)}
          <EntityLogo entity={work} />
        </span>
      {:else}
        <span class="label">{I18n('title')}:</span>
        {#if withEditor}
          <EntityResolverInput
            type="work"
            label={editionTitle}
            bind:currentEntityLabel={currentEditionLabel}
            bind:entity={work}
            bind:uri={userSelectedWorkUri}
          />
        {/if}
      {/if}
    </div>
    {#if !userSelectedWorkUri}
      <div class="authors">
        {#if isNonEmptyArray(authors)}
          <span class="label">{I18n('authors')}:</span>
          {#if editableAuthors}
            {#each authors as author}
              <EntityResolverInput
                type="human"
                bind:entity={author}
              />
            {/each}
          {:else}
            {#each authors as author, id}
              <!-- Necessary span to look like <sup> (exponent) element -->
              <span class="author-name">
                {findBestLang(author)}
                <EntityLogo entity={author} />
                <!-- prefer this to CSS :last-child, to be able to have a space after the comma -->
                {#if id !== authors.length - 1},&nbsp;{/if}
              </span>
            {/each}
          {/if}
        {/if}
      </div>
    {/if}
    <div class="isbn">
      {#if isbn13h}
        <span class="label">ISBN:</span>
        {isbn13h}
        {#if edition}
          <EntityLogo entity={edition} />
        {/if}
      {/if}
    </div>
  </div>
</div>
<style lang="scss">
  @import "#general/scss/utils";
  .entry-display{
    margin-inline-end: 1em;
    width: 100%;
    @include display-flex(row, center, space-between);
    .edition-cover{
      margin-inline-end: 1em;
      width: 4em;
      max-height: 5em;
      overflow: hidden;
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
    font-size: 0.9rem;
    margin-inline-end: 0.5em;
  }
</style>
