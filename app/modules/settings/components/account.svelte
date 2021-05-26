<script>
  import { I18n } from 'modules/user/lib/i18n'
  import preq from 'lib/preq'
  import Flash from 'lib/components/flash.svelte'
  import { languages as languagesObj } from 'lib/active_languages'
  export let user
  let showFlashLang, hideFlashLang
  const { lang } = user
  let userLanguage = languagesObj[lang]

  const pickLanguage = async selectedLang => {
    hideFlashLang()
    const body = {
      attribute: 'language',
      value: selectedLang
    }
    userLanguage = languagesObj[selectedLang]
    try {
      const res = await preq.put(app.API.user, body)
      if (res.ok) window.location.reload()
    } catch {
      showFlashLang({
        priority: 'error',
        message: I18n('something went wrong, try again later')
      })
    }
  }
</script>

<section>
  <h2 class="title first-title">{I18n('account')}</h2>
  <h3 class="label">{I18n('language')}</h3>
  <select name="language" aria-label="language picker" value="{userLanguage.lang}" on:blur="{e => pickLanguage(e.target.value)}" >
    {#each Object.values(languagesObj) as language}
      <option value={language.lang}>{language.lang} - {language.native}</option>
    {/each}
  </select>
  <Flash bind:show={showFlashLang} bind:hide={hideFlashLang}/>
</section>


<style lang="scss">
  @import 'app/modules/settings/scss/section_settings_svelte';
</style>
