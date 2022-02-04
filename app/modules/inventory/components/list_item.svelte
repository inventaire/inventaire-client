<script>
  import { I18n, i18n } from '#user/lib/i18n'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import getOriginalLang from '#entities/lib/get_original_lang'
  import getBestLangValue from '#entities/lib/get_best_lang_value'
  import EntityLogo from '#inventory/components/entity_source_logo.svelte'
  export let candidate

  const { isbnData, edition, works, authors } = candidate
  let { customWorkTitle, customAuthorsNames } = candidate
  const rawIsbn = isbnData?.rawIsbn
  let customAuthorName, work, editionLang, existingItemsCount
  if (works && works.length > 0) work = works[0]

  if (edition) {
    editionLang = getOriginalLang(edition.claims)
  } else {
    editionLang = 'en'
  }

  if (customAuthorsNames && customAuthorsNames.length > 0) {
    customAuthorName = customAuthorsNames[0]
    if (!authors && customAuthorsNames.length > 1) {
      status.warning = 'multiple authors detected, this importer can only create one author. You may add authors later.'
    }
  }

  const findBestLang = objectWithLabels => {
    if (!objectWithLabels || !objectWithLabels.labels) return
    return getBestLangValue(editionLang, null, objectWithLabels.labels).value
  }

  $: existingItemsCount = candidate.existingItemsCount
  $: candidate.customWorkTitle = customWorkTitle
  $: candidate.customAuthorName = customAuthorName
</script>
<div class="listItem">
  {#if edition?.image?.url}
    <div class="candidateCover">
      <img src="{imgSrc(edition.image.url, 80)}" alt='{findBestLang(work, editionLang)} cover'>
    </div>
  {/if}
  <div class="textWrapper">
    <div class="column work">
      <span class="label">{i18n('title')}:</span>
      {#if work}
        <span class="workTitle">
          {findBestLang(work, editionLang)}
          <EntityLogo uri="{work.uri}"/>
        </span>
      {:else}
        <input
          on:click|stopPropagation
          type="text"
          name="customWorkTitle"
          class="customInput"
          bind:value={customWorkTitle}
          placeholder="{I18n('write book title')}">
      {/if}
    </div>
    <span class="column authors">
      <span class="label">{i18n('authors')}:</span>
      {#if authors}
        {#each authors as author, id}
          <span class="authorName">
            {findBestLang(author)}
            <EntityLogo uri="{author.uri}"/>
            {#if id !== authors.length - 1},&nbsp;{/if}
          </span>
        {/each}
      {:else}
        <input
          on:click|stopPropagation
          type="text"
          name="customAuthorName"
          class="customInput"
          bind:value={customAuthorName}
        >
      {/if}
    </span>
    <div class="column isbn">
      {#if rawIsbn}
        <span class="label">ISBN:</span>
        {rawIsbn}
      {/if}
    </div>
  </div>
</div>
<style lang="scss">
  @import 'app/modules/general/scss/utils';
  .column{
    flex: 20 0 0;
    padding: 0.2em;
  }
  .listItem{
    flex: 1 0 0;
    @include display-flex(row, center);
    .candidateCover{
      margin-right: 1em;
    };
    .textWrapper{
      @include display-flex(row, center);
      flex: 1 0 0;
      .isbn{
        @include display-flex(column);
        text-align: right;
        flex: 5 0 0;
      }
      .status{
        @include display-flex(column);
        text-align: right;
        flex: 7 0 0;
      }
      .label{
        display: none;
      }
    }
  }
  .authors, .work{
    @include display-flex(row, center, center, wrap);
      width: 100%;
    .customInput{
      margin-bottom: 0;
      width: 100%;
    }
  }

  /*Small screens*/
  @media screen and (max-width: 45em) {
    .listItem{
      .textWrapper{
        @include display-flex(column, center);
        .column{
          text-align: left;
        }
        .isbn{
          @include display-flex(row, center);
        }
        .label{
          display: inline;
          color: $grey;
          margin-right: 0.5em;
        }
      }
    }
  }
</style>
