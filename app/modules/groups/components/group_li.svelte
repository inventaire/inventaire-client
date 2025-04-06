<script lang="ts">
  import Flash from '#app/lib/components/flash.svelte'
  import type { FlashState } from '#app/lib/components/flash.svelte'
  import { icon } from '#app/lib/icons'
  import { imgSrc } from '#app/lib/image_source'
  import { loadInternalLink } from '#app/lib/utils'
  import Spinner from '#components/spinner.svelte'
  import { i18n, I18n } from '#user/lib/i18n'
  import { acceptGroupInvitation, declineGroupInvitation, type SerializedGroup } from '../lib/groups'

  export let group: SerializedGroup

  const { name, pathname, picture, description } = group

  // @ts-expect-error
  const pictureUrl = imgSrc(picture, 100)

  let flash: FlashState

  let accepting = false
  let done = false
  async function accept () {
    try {
      accepting = true
      await acceptGroupInvitation({ groupId: group._id })
    } catch (err) {
      flash = err
    } finally {
      accepting = false
      onceDone()
    }
  }

  let declining = false
  async function decline () {
    try {
      declining = true
      await declineGroupInvitation({ groupId: group._id })
    } catch (err) {
      flash = err
    } finally {
      declining = false
      onceDone()
    }
  }

  function onceDone () {
    flash = { type: 'success', message: '', canBeClosed: false }
    done = true
    setTimeout(() => flash = null, 1000)
  }
</script>

<div class="group">
  <a href={pathname} class="show-group" on:click={loadInternalLink}>
    <div class="group-cover-picture" style:background-image="url('{pictureUrl}')"></div>
    <div class="info">
      <p class="name">{name}</p>
      <p class="description">{description}</p>
    </div>
  </a>
  <div class="actions">
    {#if flash}
      <Flash bind:state={flash} />
    {:else if done}
      <a href={group.pathname} on:click={loadInternalLink} class="action tiny-button light-blue">
        {i18n('See group')}
      </a>
    {:else}
      <button class="accept tiny-button light-blue" on:click={accept} disabled={accepting || declining}>
        {#if accepting}
          <Spinner light={true} />
        {:else}
          {@html icon('check')}
        {/if}
        {I18n('accept invitation')}
      </button>
      <button class="decline tiny-button" on:click={decline} disabled={accepting || declining}>
        {#if declining}
          <Spinner light={true} />
        {:else}
          {@html icon('minus')}
        {/if}
        {I18n('decline')}
      </button>
    {/if}
  </div>
</div>

<style lang="scss">
  @import '#general/scss/utils';

  .group{
    @include display-flex(row, center, space-between);
    background-color: white;
    padding: 0.5em;
    @include radius;
  }
  .group-cover-picture{
    @include bg-cover;
    height: 5em;
    width: 5em;
    flex: 0 0 auto;
  }
  .show-group{
    font-weight: bold;
    .info{
      text-align: start;
      padding: 0.5em;
    }
    .name{
      font-weight: bold;
    }
    .description{
      color: $grey;
      max-height: 10em;
      overflow: auto;
    }
  }
  .actions{
    min-width: 12rem;
    @include display-flex(column);
    flex: 0 0 auto;
    button{
      text-align: start;
    }
    button:not(:last-child){
      margin-block-end: 0.5rem;
    }
  }
  /* Small screens */
  @media screen and (width < $smaller-screen){
    .group{
      flex-direction: column;
    }
    .show-group{
      @include display-flex(column, center, center);
    }
    .name{
      text-align: center;
    }
    .description{
      max-height: 3em;
    }
  }

  /* Large screens */
  @media screen and (width >= $small-screen){
    .show-group{
      @include display-flex(row, flex-start, flex-start);
      flex: 1 0 0;
      margin-inline-end: 0.5em;
    }
    .description{
      overflow: auto;
    }
  }
</style>
