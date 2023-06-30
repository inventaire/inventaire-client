<script>
  import { I18n, i18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import { translate } from '#lib/urls'
  import languages from '#assets/js/languages_data'
  import Link from '#lib/components/link.svelte'
  import Dropdown from '#components/dropdown.svelte'

  const mostCompleteFirst = (a, b) => b.completion - a.completion
  const languagesList = _.values(languages).sort(mostCompleteFirst)
  const currentLanguage = languages[app.user.lang].native
  const currentLanguageShortName = languages[app.user.lang].lang.toUpperCase()

  function selectLang (lang) {
    // Remove the querystring lang parameter to be sure that the picked language
    // is the next language taken in account
    app.execute('querystring:set', 'lang', null)

    if (app.user.loggedIn) {
      return app.request('user:update', {
        attribute: 'language',
        value: lang,
      })
    } else {
      return app.user.set('language', lang)
    }
  }
</script>

<div class="language-picker">
  <Dropdown>
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
    padding-inline-start: 0.5em;
    align-self: stretch;
    @include display-flex(row, stretch, center);
    :global(.dropdown-button){
      @include bg-hover-lighten-svelte($topbar-bg-color);
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
  [slot="dropdown-content"]{
    min-width: min(18em, 100vw);
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
  @media screen and (min-width: $very-small-screen){
    .current-lang-short{
      display: none;
    }
  }
  /* Smaller screens */
  @media screen and (max-width: $very-small-screen){
    .current-lang{
      display: none;
    }
  }
</style>
