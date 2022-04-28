<script>
  import { i18n } from '#user/lib/i18n'
  import Dropdown from '#components/dropdown.svelte'
  import { icon } from '#lib/utils'
  import languages from '#lib/languages_data'

  export let selectedLangs, editionsLangs, triggerScrollToMap

  const nativeLanguage = lang => languages[lang].native
</script>
<button
  class="map-button"
  on:click="{() => triggerScrollToMap = true}"
  title="{i18n('show on map users who have these editions')}"
>
  {@html icon('map-marker')} {i18n('show editions map')}
</button>
<div class="menu-wrapper">
  <Dropdown
    buttonTitle={i18n('Show langs')}
    >
    <div slot="button-inner">
      {@html icon('language')}{i18n('filter editions by lang')}
    </div>
    <ul slot="dropdown-content">
      <li class="dropdown-element">
        <div on:click="{() => { selectedLangs = editionsLangs }}">
          {i18n('all languages')}
        </div>
      </li>
      {#each editionsLangs as lang}
        <li class="dropdown-element">
          <label>
            <input type="checkbox" bind:group={selectedLangs} value={lang} />
            {lang} - {nativeLanguage(lang)}
          </label>
        </li>
      {/each}
    </ul>
  </Dropdown>
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .language-filter{
    max-width: 10em;
  }
  .map-button{
    @include tiny-button($grey);
    padding: 0.5em;
    margin: 0.3em;
  }
  // Dropdown
  .menu-wrapper{
    /*Small screens*/
    @media screen and (max-width: $smaller-screen) {
      margin-right: 0.5em;
    }
    /*Large screens*/
    @media screen and (min-width: $smaller-screen) {
      right: 0;
    }
    @include display-flex(column, flex-end);
    :global(.dropdown-button){
      @include tiny-button($grey);
      padding: 0.5em;
    }
  }
  [slot="dropdown-content"]{
    @include shy-border;
    background-color:white;
    @include radius;
    // z-index known cases: items map
    z-index: 1;
    position: relative;
    li{
      @include bg-hover(white, 10%);
      @include display-flex(row, center, flex-start);
      min-height: 3em;
      cursor:pointer;
      padding: 0 1em;
      &:not(:last-child){
        margin-bottom: 0.2em;
      }
      :global(.error){
        flex: 1;
      }
    }
  }
</style>
