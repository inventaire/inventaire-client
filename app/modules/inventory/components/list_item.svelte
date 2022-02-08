<script>
  import { I18n, i18n } from '#user/lib/i18n'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import getOriginalLang from '#entities/lib/get_original_lang'
  import getBestLangValue from '#entities/lib/get_best_lang_value'
  import EntityLogo from '#inventory/components/entity_source_logo.svelte'
  export let isbnData
  export let edition
  export let works
  export let authors
  export let customWorkTitle
  export let customAuthorsNames
  export let withEditor = false

  const rawIsbn = isbnData?.rawIsbn
  let customAuthorName, work, editionLang
  if (works && works.length > 0) work = works[0]

  if (edition) {
    editionLang = getOriginalLang(edition.claims)
  } else {
    editionLang = 'en'
  }

  if (customAuthorsNames && customAuthorsNames.length > 0) {
    customAuthorName = customAuthorsNames[0]
  }

  const findBestLang = objectWithLabels => {
    if (!objectWithLabels || !objectWithLabels.labels) return
    return getBestLangValue(editionLang, null, objectWithLabels.labels).value
  }
</script>
<div class="listItem">
    <div class="editionCover">
      {#if edition?.image?.url}
        <img src="{imgSrc(edition.image.url, 80)}" alt='{findBestLang(work, editionLang)} cover'>
      {/if}
    </div>
    <div class="textWrapper">
      <div class="column work">
        {#if work}
          <span class="label">{i18n('title')}:</span>
          <span class="workTitle">
            {findBestLang(work, editionLang)}&nbsp;
            <EntityLogo entity="{work}"/>
          </span>
        {:else}
          {#if withEditor}
            <span class="editorRow">
              <span class="label">{i18n('title')}:</span>
              <input
                on:click|stopPropagation
                type="text"
                name="customWorkTitle"
                class="customInput"
                bind:value={customWorkTitle}
                placeholder="{I18n('must have book title')}">
            </span>
          {/if}
        {/if}
      </div>
      <span class="column authors">
        {#if authors && authors.length > 0}
          <span class="label">{i18n('authors')}:</span>
          {#each authors as author, id}
            <span class="authorName">
              {findBestLang(author)}&nbsp;
              <EntityLogo entity="{author}"/>
              {#if id !== authors.length - 1},&nbsp;{/if}
            </span>
          {/each}
        {:else}
          {#if withEditor}
            <span class="editorRow">
              <span class="label">{i18n('authors')}:</span>
              <input
                on:click|stopPropagation
                type="text"
                name="customAuthorName"
                class="customInput"
                bind:value={customAuthorName}
              >
            </span>
          {/if}
        {/if}
      </span>
      <div class="column isbn">
        {#if rawIsbn}
          <span class="label">ISBN:</span>
          {rawIsbn}
          {#if edition}
            &nbsp;
            <EntityLogo entity="{edition}"/>
          {/if}
        {/if}
      </div>
    </div>
</div>
<style lang="scss">
  @import '#general/scss/utils';
  .listItem{
    margin-right: 1em;
    @include display-flex(row, center, space-between);
    .editionCover{
      margin-right: 1em;
      min-width: 4em;
    }
  }
  .column{
    padding: 0.1em 0;
  }
  .textWrapper{
    @include display-flex(column);
    width: 100%;
    padding: 0.2em 0;
  }
  .label{
    display: inline;
    color: $grey;
    font-size: 90%;
    margin-right: 0.5em;
  }
</style>
