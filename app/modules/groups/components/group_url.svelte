<script>
  import { isNonEmptyString } from '#lib/boolean_tests'
  import preq from '#lib/preq'
  import { onChange } from '#lib/svelte/svelte'
  import { I18n } from '#user/lib/i18n'
  import { debounce } from 'underscore'

  export let name
  export let groupId
  export let flash

  let url

  async function updateUrl () {
    try {
      if (isNonEmptyString(name)) {
        const { slug } = await preq.get(app.API.groups.slug(name, groupId))
        url = `${window.location.origin}/groups/${slug}`
      } else {
        url = null
      }
    } catch (err) {
      flash = err
    }
  }
  const lazyUpdateUrl = debounce(updateUrl, 200)

  $: onChange(name, lazyUpdateUrl)
</script>

{#if url}
  <p class="group-url">
    <span>{I18n('group URL:')}</span>
    <span id="groupUrl">{url}</span>
  </p>
{/if}
