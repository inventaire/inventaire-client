<script lang="ts">
  import { API } from '#app/api/api'
  import Flash from '#app/lib/components/flash.svelte'
  import preq from '#app/lib/preq'
  import { getLocalTimeString, timeFromNow } from '#app/lib/time'
  import { loadLink } from '#app/lib/utils'
  import { commands } from '#app/radio'
  import Operation from '#entities/components/patches/operation.svelte'
  import type { SerializedPatch } from '#entities/lib/patches'
  import { i18n, I18n } from '#user/lib/i18n'

  export let patch: SerializedPatch

  let flash

  const { _id: patchId, versionNumber, invEntityUri, operations, timestamp, context, contributor } = patch

  async function revert () {
    try {
      await preq.put(API.entities.revertEdit, { patch: patchId })
      commands.execute('show:entity:history', invEntityUri)
    } catch (err) {
      flash = err
    }
  }
</script>

<div class="patch">
  <p>
    <span class="label">id:</span>
    <span class="value">{patchId}</span>
  </p>
  <p>
    <span class="label">{i18n('version')}:</span>
    <span class="value">{versionNumber}</span>
  </p>
  <p>
    <span class="label">{i18n('user')}:</span>
    {#if contributor}
      {#if contributor.special}
        <span class="value">{contributor.username}</span>
        <span class="special-user">{I18n('special user')}</span>
      {:else if contributor.deleted}
        <span class="value">{contributor.username}</span>
        <span class="deleted-user">{i18n('deleted')}</span>
      {:else if contributor.pathname}
        <a class="value show-user" href={contributor.pathname} on:click={loadLink}>{contributor.handle || contributor.acct}</a>
      {:else}
        <span class="value">{contributor.username || contributor.acct}</span>
      {/if}
      <a class="show-user-contributions" href={contributor.contributionsPathname} on:click={loadLink}>
        {i18n('contributions')}
      </a>
    {:else}
      <span class="value"><em>{i18n('anonymized')}</em></span>
    {/if}
  </p>
  <p>
    <span class="label">{i18n('date')}:</span>
    <span class="value">
      <span class="time-from-now">{timeFromNow(timestamp)}</span>
      <span class="precise-time">{getLocalTimeString(timestamp)}</span>
    </span>
  </p>
  {#if context && 'mergeFrom' in context}
    <p>
      <span class="label">{i18n('context')}</span>
      <span class="value">
        merge from <a href="/entity/{context.mergeFrom}" on:click={loadLink}>{context.mergeFrom}</a>
      </span>
    </p>
  {/if}
  <div>
    <span class="label">{i18n('operations')}:</span>
    <ul>
      {#each operations as operation}
        <Operation {operation} />
      {/each}
    </ul>
  </div>
  <ul class="actions">
    <li>
      <button class="revert tiny-button" on:click={revert}>{I18n('undo')}</button>
    </li>
  </ul>
  <Flash state={flash} />
</div>

<style lang="scss">
  @import "#general/scss/utils";
  .patch{
    background-color: $darker-grey;
    @include radius;
    padding: 0.5em;
    margin: 0.5em 0;
    /* Medium and Large screens */
    @media screen and (width >= $very-small-screen){
      margin: 0.5em;
    }
  }
  .show-user{
    color: white;
    @include underline-on-hover(white);
  }
  .label{
    font-weight: bold;
    // Allow to set a width
    display: inline-block;
    width: 6em;
  }
  .special-user{
    background-color: rgba($grey, 0.5);
    @include radius;
    padding: 0.2em;
    font-size: 0.9em;
    margin-inline-start: 0.2em;
  }
  .deleted-user{
    color: red;
    padding-inline-start: 0.2em;
  }
  .precise-time{
    color: #bbb;
    font-weight: 0.8em;
    padding-inline-start: 0.5em;
  }
  .show-user-contributions{
    color: #bbb;
    margin-inline-start: 0.5em;
  }
  .actions{
    margin-block-start: 1em;
    @include display-flex(row);
  }
</style>
