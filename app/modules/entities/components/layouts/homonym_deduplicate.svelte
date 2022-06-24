<script>
  import Flash from '#lib/components/flash.svelte'
  import Link from '#lib/components/link.svelte'
  import Infobox from './infobox.svelte'
  import Spinner from '#general/components/spinner.svelte'
  import { I18n, i18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import preq from '#lib/preq'

  import getFavoriteLabel from '#entities/lib/get_favorite_label'
  import { getWorkProperties } from '#entities/components/lib/claims_helpers'

  export let homonym, entity, childEvents

  let isMerging
  let flash

  const workShortlist = [
    'wdt:P50',
    'wdt:P577',
    'wdt:P136',
    'wdt:P921',
  ]

  export const merge = async () => {
    if (isMerging) return
    isMerging = true

    await preq.put(app.API.entities.merge, {
      from: homonym.uri,
      to: entity.uri
    })
    .then(() => {
      flash = {
        type: 'success',
        message: I18n('merged')
      }
      homonym.merged = true
    })
    .catch(err => {
      flash = err
    })
    .finally(() => {
      isMerging = false
    })
  }
  childEvents = { merge }
</script>

<div
  class="homonym"
  on:click={() => { homonym.checked = !homonym.checked }}
>
  <div>
    <input type="checkbox"
      bind:checked={homonym.checked}
      name={I18n('merge')}
    >
  </div>
  <div class="homonym-info">
    <div class="homonym-title">
      <Link
        url={`/entity/${homonym.uri}`}
        text={getFavoriteLabel(homonym)}
        dark={true}
      />
    </div>
    <Infobox
      claims={homonym.claims}
      propertiesLonglist={getWorkProperties()}
      propertiesShortlist={workShortlist}
      entityType="work"
    />
    <div class="button-wrapper">
      <button
        class="tiny-button"
        on:click|stopPropagation={merge}
        >
          {#if isMerging}
            <Spinner/>
          {:else}
            {@html icon('compress')}
          {/if}
          {i18n('merge')}
      </button>
    </div>
    <div class="flash">
      <Flash bind:state={flash}/>
    </div>
  </div>
</div>
<style lang="scss">
  @import '#general/scss/utils';
  .homonym{
    min-width: 15em;
    @include display-flex(row, center, center, wrap);
    padding: 1em;
    margin: 0.5em;
    cursor: pointer;
    background-color: $off-white;
  }
  .homonym-info{
    margin-left: 1em;
  }
  .homonym-title{
    font-size: larger
  }
  .button-wrapper{
    margin-top: 1em;
    @include display-flex(row, center, center, wrap);
  }
  .tiny-button{
    padding: 0.5em;
  }
  .flash{
    max-width: 15em;
  }
</style>
