<script>
  import { createEventDispatcher } from 'svelte'
  import { isNonEmptyString } from '#app/lib/boolean_tests'
  import { getNativeLangName } from '#entities/components/editor/lib/editors_helpers'

  const dispatch = createEventDispatcher()

  export let lang, value, currentLang

  $: native = getNativeLangName(lang)
  $: isNotEmptyNorRemoved = isNonEmptyString(value) || value !== Symbol.for('removed')
</script>
{#if lang !== currentLang && isNotEmptyNorRemoved}
  <li>
    <button
      class="edit-other-language"
      on:click={() => dispatch('editLanguageValue', lang)}
    >
      <span class="lang">{lang} {#if native}- {native}{/if}</span>
      <span class="other-value">{value}</span>
    </button>
  </li>
{/if}
<style lang="scss">
  @use "#general/scss/utils";
  .edit-other-language{
    inline-size: 100%;
    margin: 0.5em 0;
    padding: 0.5em 0;
    @include display-flex(row, center, flex-start);
    @include bg-hover(white, 5%);
    text-align: start;
  }
  .other-value{
    user-select: text;
  }
  /* Large screens */
  @media screen and (width >= $smaller-screen){
    .other-value{
      margin: 0 1.1em;
    }
    .lang{
      inline-size: 10em;
      block-size: 100%;
      padding-inline-start: 0.7rem;
      font-size: 0.9rem;
    }
  }
</style>
