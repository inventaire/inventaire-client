<script lang="ts">
  import { languages } from '#app/lib/active_languages'
  import Link from '#app/lib/components/link.svelte'
  import { icon } from '#app/lib/icons'
  import { translate } from '#app/lib/urls'
  import { commands } from '#app/radio'
  import Dropdown from '#components/dropdown.svelte'
  import { I18n, i18n } from '#user/lib/i18n'
  import { mainUser, updateUser } from '#user/lib/main_user'

  const mostCompleteFirst = (a, b) => b.completion - a.completion
  const languagesList = Object.values(languages).sort(mostCompleteFirst)
  const currentLanguage = languages[mainUser.lang].native
  const currentLanguageShortName = languages[mainUser.lang].lang.toUpperCase()

  function selectLang (lang) {
    // Remove the querystring lang parameter to be sure that the picked language
    // is the next language taken in account
    commands.execute('querystring:set', 'lang', null)
    return updateUser('language', lang)
  }
</script>

<div class="language-picker">
  <Dropdown dropdownWidthBaseInEm={18}>
    <div slot="button-inner">
      <span class="current-lang">{currentLanguage}</span>
      <span class="current-lang-short">{currentLanguageShortName}</span>
      {@html icon('caret-down')}
    </div>
    <div slot="dropdown-content">
      <ul class="options">
        {#each languagesList as { lang, native, completion } (lang)}
          <li class="option">
            <button
              title="{i18n('switch_to_lang', { language: native })} ({i18n('translation_completion', { completion })})"
              on:click={() => selectLang(lang)}
            >
              <span class="completion" style:width={`${completion}%`} />
              <span class="lang" {lang}>{native}</span>
              <span class="completion-text">({completion}%)</span>
            </button>
          </li>
        {/each}
      </ul>
      <div class="help-translate">
        <Link
          url={translate}
          icon="pencil"
          text={I18n('help translate Inventaire')}
        />
      </div>
    </div>
  </Dropdown>
</div>

<style lang="scss">
  @import "#general/scss/utils";
  .language-picker{
    margin-inline-start: 0.2em;
    align-self: stretch;
    @include display-flex(row, stretch, center);
    :global(.dropdown-button){
      @include bg-hover-lighten-svelte($topbar-bg-color);
      padding-inline-start: 0.5em;
    }
    :global(.fa-caret-down){
      color: #ccc;
    }
  }
  [slot="button-inner"]{
    @include serif;
    font-weight: bold;
    color: white;
    white-space: nowrap;
    span{
      color: white;
    }
  }
  .options{
    overflow-y: auto;
    overflow-x: hidden;
    max-height: 60vh;
  }
  li.option{
    @include display-flex(row, stretch);
    button{
      flex: 1 0 auto;
      padding: 0.4em 0;
      position: relative;
      z-index: 1;
      background-color: $grey;
      border-radius: 0;
      text-align: start;
      &, span{
        color: white !important;
      }
      &:focus{
        background-color: $dark-grey;
        .completion{
          opacity: 0.25;
          background-color: $dark-grey;
        }
      }
    }
    .completion{
      position: absolute;
      inset-block: 0;
      inset-inline-start: 0;
      z-index: -1;
      background-color: $light-blue;
    }
    .lang{
      font-weight: bold;
      padding: 0 0.5em;
    }
    .completion-text{
      margin-inline-start: auto;
      font-weight: normal;
      opacity: 0.8;
    }
    &:hover{
      .completion{
        opacity: 0.25;
      }
      button{
        background-color: $dark-grey;
      }
    }
    &:not(:last-child) .completion{
      border-end-end-radius: $global-radius;
    }
  }
  .help-translate{
    :global(a){
      @include display-flex(row, center, flex-start);
      flex: 1 0 auto;
      align-self: stretch;
      font-weight: bold;
      @include serif;
      @include bg-hover-lighten-svelte($topbar-bg-color);
      font-size: 1rem;
      padding: 0.8rem 1rem;
      @include radius-bottom;
    }
    :global(.fa), :global(.link-text){
      color: white;
    }
  }
  /* Not Too Small screens */
  @media screen and (width >= $very-small-screen){
    .current-lang-short{
      display: none;
    }
  }
  /* Very small screens */
  @media screen and (width < $very-small-screen){
    .current-lang{
      display: none;
    }
  }
</style>
