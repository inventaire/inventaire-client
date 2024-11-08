<script lang="ts">
  import { API } from '#app/api/api'
  import app from '#app/app'
  import Flash from '#app/lib/components/flash.svelte'
  import Link from '#app/lib/components/link.svelte'
  import { icon } from '#app/lib/icons'
  import preq from '#app/lib/preq'
  import { unprefixify } from '#app/lib/wikimedia/wikidata'
  import Dropdown from '#components/dropdown.svelte'
  import Modal from '#components/modal.svelte'
  import Spinner from '#components/spinner.svelte'
  import { getEntityLabel, getWikidataHistoryUrl, getWikidataUrl, hasLocalLayer } from '#entities/lib/entities'
  import type { SerializedEntity } from '#entities/lib/entities'
  import { checkWikidataMoveabilityStatus, moveToWikidata } from '#entities/lib/move_to_wikidata'
  import { i18n, I18n } from '#user/lib/i18n'

  export let entity: SerializedEntity

  let flash
  const { uri, isWikidataEntity, label, historyPathname } = entity
  const { invUri, wdUri } = entity
  const { hasDataadminAccess } = app.user
  let wikidataUrl, wikidataHistoryUrl
  if (wdUri) {
    wikidataUrl = getWikidataUrl(wdUri)
    wikidataHistoryUrl = getWikidataHistoryUrl(wdUri)
  }
  const canBeDeleted = !isWikidataEntity
  let waitForWikidataMove
  let canBeMovedToWikidata, moveabilityStatus
  $: ({ ok: canBeMovedToWikidata, reason: moveabilityStatus } = checkWikidataMoveabilityStatus(entity))

  let moveConflict
  async function _moveToWikidata () {
    flash = null
    try {
      if (!app.user.hasWikidataOauthTokens()) {
        return app.execute('show:wikidata:edit', invUri)
      }
      await moveToWikidata(invUri)
      // This should now redirect us to the new Wikidata edit page
      app.execute('show:entity:edit', uri)
    } catch (err) {
      const conflicts = err.responseJSON?.context?.conflicts
      if (err.message.includes('same identifiers') && conflicts.length > 0) {
        const conflictsData = await Promise.all(conflicts.map(async ({ subject, property, value }) => {
          const { label: subjectLabel } = await getEntityLabel(subject)
          const url = `${getWikidataUrl(subject)}#${unprefixify(property)}`
          return { subject, subjectLabel, property, value, url }
        }))
        err.canBeClosed = false
        moveConflict = {
          err,
          conflictsData,
        }
      } else {
        flash = err
      }
    }
  }

  function reportDataError (e) {
    flash = null
    app.execute('show:feedback:menu', {
      subject: `[${uri}][${I18n('data error')}] `,
      uris: [ uri ],
      event: e,
    })
  }

  function loadSettings () {
    app.execute('show:settings:display')
  }

  function deleteEntity () {
    flash = null
    app.execute('ask:confirmation', {
      confirmationText: I18n('delete_entity_confirmation', { label }),
      action: _deleteEntity,
    })
  }

  async function _deleteEntity () {
    try {
      await preq.post(API.entities.delete, { uris: [ invUri ] })
      app.execute('show:entity:edit', uri)
    } catch (err) {
      // TODO: recover displayDeteEntityErrorContext feature to show rich error message
      flash = err
      throw err
    }
  }
</script>

<div class="menu-wrapper">
  <Dropdown buttonTitle={i18n('Show actions')} dropdownWidthBaseInEm={14}>
    <div slot="button-inner">
      {@html icon('cog')}
    </div>
    <ul slot="dropdown-content">
      {#if wikidataUrl}
        <li>
          <Link
            url={wikidataUrl}
            text={I18n('see_on_website', { website: 'wikidata.org' })}
            icon="wikidata"
          />
        </li>
      {/if}
      {#if wikidataHistoryUrl && !hasLocalLayer(entity)}
        <li>
          <Link
            url={wikidataHistoryUrl}
            text={I18n('entity history')}
            icon="history"
          />
        </li>
      {:else}
        <li>
          <Link
            url={historyPathname}
            text={I18n('entity history')}
            icon="history"
          />
        </li>
      {/if}
      <li>
        <Link
          url="/entity/merge?from={uri}"
          text={I18n('merge')}
          icon="compress"
        />
      </li>
      {#if hasDataadminAccess}
        {#if canBeDeleted}
          <li>
            <button
              title={I18n('delete entity')}
              on:click={deleteEntity}
            >
              {@html icon('trash')}
              {I18n('delete')}
            </button>
          </li>
        {/if}
      {/if}
      {#if !isWikidataEntity}
        <li>
          <button
            disabled={!canBeMovedToWikidata}
            title={moveabilityStatus}
            on:click={() => waitForWikidataMove = _moveToWikidata()}
          >
            {#await waitForWikidataMove}
              <Spinner />
            {:then}
              {@html icon('wikidata')}
            {/await}
            {I18n('move to Wikidata')}
          </button>
        </li>
      {/if}
      <li>
        <button
          title={I18n('report_an_error_in_entity_data')}
          on:click={reportDataError}
        >
          {@html icon('flag')}
          {I18n('report an error')}
        </button>
      </li>
      <li>
        <button
          class="show-props-menu"
          on:click={loadSettings}
        >
          {@html icon('wrench')}
          {I18n('customize editable properties')}
        </button>
      </li>
      {#if flash}
        <li>
          <Flash bind:state={flash} />
        </li>
      {/if}
    </ul>
  </Dropdown>
</div>

{#if moveConflict}
  <Modal on:closeModal={() => moveConflict = null}>
    <div class="move-conflict">
      <Flash state={moveConflict.err} />
      <ul>
        {#each moveConflict.conflictsData as { subject, subjectLabel, property, value, url }}
          <li>
            <a
              href={url}
              target="_blank"
              rel="noopener"
              class="link"
            >
              <p class="subject">{subjectLabel} <span class="identifier">({subject})</span></p>
              <p class="property-and-value">{@html icon('caret-right')}{i18n(property)} <span class="identifier">({property})</span>: {value}</p>
            </a>
            <Link
              url={`/entity/merge?from=${uri}&to=${subject}`}
              text={I18n('merge')}
              icon="compress"
              tinyButton={true}
              classNames="light-blue"
            />
          </li>
        {/each}
      </ul>
  </Modal>
{/if}

<style lang="scss">
  @import "#general/scss/utils";
  .menu-wrapper{
    $entity-edit-max-width: 40em;
    /* Small screens */
    @media screen and (width < $entity-edit-max-width){
      margin-inline-end: 0.5em;
      padding: 0.5em;
    }
    /* Larger screens */
    @media screen and (width >= $entity-edit-max-width){
      position: absolute;
      inset-inline-end: 0;
      inset-block-start: 1.4em;
    }
    :global(.dropdown-button){
      @include big-button($grey);
      padding: 0.8rem;
    }
    :global(.small-spinner){
      // Aligning with other icons
      margin-inline: -4px 3px;
    }
  }
  [slot="button-inner"]{
    :global(.fa){
      font-size: 1.2rem;
    }
  }
  [slot="dropdown-content"]{
    @include shy-border;
    background-color: white;
    @include radius;
    button, :global(a:not(.link)){
      font-weight: normal;
      flex: 1;
      @include display-flex(row, center, flex-start);
      text-align: start;
      @include bg-hover(white, 5%);
      padding: 0.5em;
      :global(.fa){
        margin-inline-end: 0.5em;
      }
    }
    li{
      @include display-flex(row, stretch);
      min-block-size: 3em;
      &:not(:last-child){
        margin-block-end: 0.2em;
      }
      :global(.error){
        flex: 1;
      }
    }
  }
  button:disabled{
    @include shy(0.9);
  }
  .move-conflict{
    li{
      @include display-flex(column, center, center);
      @include radius;
      background-color: $light-grey;
      margin: 0.5rem 0;
      padding: 0.5rem;
      a{
        align-self: flex-start;
        margin: 0.5rem;
      }
    }
    .subject{
      font-weight: bold;
    }
    .identifier{
      @include identifier;
    }
  }
</style>
