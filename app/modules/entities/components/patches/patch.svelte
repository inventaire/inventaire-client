<script>
  import Operation from '#entities/components/patches/operation.svelte'
  import Flash from '#lib/components/flash.svelte'
  import preq from '#lib/preq'
  import { getlocalTimeString, timeFromNow } from '#lib/time'
  import { loadInternalLink } from '#lib/utils'
  import { i18n, I18n } from '#user/lib/i18n'

  export let patch

  let flash

  const { _id: patchId, versionNumber, invEntityUri, operations, timestamp, context, user } = patch

  async function revert () {
    try {
      await preq.put(app.API.entities.revertEdit, { patch: patchId })
      app.execute('show:entity:history', invEntityUri)
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
    {#if user}
      {#if user.special}
        <span class="value">{user.username}</span>
        <span class="special-user">{I18n('special user')}</span>
      {:else if user.deleted}
        <span class="value">{user.username}</span>
        <span class="deleted-user">{i18n('deleted')}</span>
      {:else}
        <a class="value show-user" href={user.pathname} on:click={loadInternalLink}>{user.username}</a>
      {/if}
      <a class="show-user-contributions" href={user.contributionsPathname} on:click={loadInternalLink}>
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
      <span class="precise-time">{getlocalTimeString(timestamp)}</span>
    </span>
  </p>
  {#if context?.mergeFrom}
    <p>
      <span class="label">{i18n('context')}</span>
      <span class="value">
        merge from <a href="/entity/{context.mergeFrom}" on:click={loadInternalLink}>{context.mergeFrom}</a>
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
    @media screen and (min-width: $very-small-screen){
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
