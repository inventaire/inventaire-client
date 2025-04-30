<script lang="ts">
  import { createEventDispatcher } from 'svelte'
  import { isNonEmptyString } from '#app/lib/boolean_tests'
  import LanguageLabel from '../language_label.svelte'
  import type { WikimediaLanguageCode } from 'wikibase-sdk'

  const dispatch = createEventDispatcher()

  export let lang: WikimediaLanguageCode
  export let value: string | symbol = null
  export let lastAddedLang: WikimediaLanguageCode
</script>

{#if isNonEmptyString(value)}
  <li data-lang={lang}>
    <button
      class="edit-language-label"
      class:highlight={lastAddedLang === lang}
      on:click={() => dispatch('editLanguageValue', lang)}
    >
      <LanguageLabel {lang} />
      <span class="value">{value}</span>
    </button>
  </li>
{/if}

<style lang="scss">
  @import "#general/scss/utils";
  .edit-language-label{
    inline-size: 100%;
    @include bg-hover(white, 5%);
    text-align: start;
  }
  .highlight{
    @include flash(lighten($success-color, 30%));
  }
  .value{
    user-select: text;
  }
  /* Large screens */
  @media screen and (width >= $smaller-screen){
    .edit-language-label{
      height: 3rem;
      @include display-flex(row, center, flex-start);
    }
    .value{
      // Align with .edited-label
      margin: 0 0.55em;
    }
  }
  /* Small screens */
  @media screen and (width < $smaller-screen){
    .edit-language-label{
      margin: 0.5rem 0;
      .value{
        display: block;
        padding: 0.2rem;
        background-color: $light-grey;
      }
    }
  }
</style>
