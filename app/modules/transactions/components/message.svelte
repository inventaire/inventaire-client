<script lang="ts">
  import { imgSrc } from '#app/lib/image_source'
  import { getLocalTimeString, timeFromNow } from '#app/lib/time'
  import { userContent } from '#app/lib/user_content'
  import { loadInternalLink } from '#app/lib/utils'

  export let messageDoc

  const { created, message, userDoc, sameUser, sameMessageGroup } = messageDoc
  const { picture, pathname, username } = userDoc
</script>

<div class="message" class:sameMessageGroup>
  <div class="avatar" class:sameUser>
    {#if !sameUser}
      {#if picture}
        <div class="innerAvatar">
          <a
            href={pathname}
            class="showUser"
            title={username}
            on:click={loadInternalLink}
          >
            <img src={imgSrc(picture, 36)} alt={username} />
          </a>
        </div>
      {/if}
    {/if}
  </div>
  <div class="rest">
    <p class="message-text">{@html userContent(message)}</p>
    {#if !sameMessageGroup}
      <p class="time" title={getLocalTimeString(created)}>{timeFromNow(created)}</p>
    {/if}
  </div>
</div>

<style lang="scss">
  @use '#general/scss/utils';
  @use '#transactions/scss/transactions_commons';
  .message{
    &:not(.sameMessageGroup){
      margin-block-start: 0.5em;
    }
    @include display-flex(row);
    // Somehow required to make .message-text long words wrap
    overflow: hidden;
    .avatar{
      flex: 0 0 36px;
      // Display over the timeline line
      z-index: 1;
      &:not(.sameMessageGroup){
        margin-block-start: 0.3em;
        @include event-icon;
      }
    }
    .rest{
      @include radius;
      background-color: #f9f9f9;
      margin-inline-start: 0.2em;
      padding: 0.5em;
      padding-inline-start: 1em;
      flex: 1 1 auto;
      @include display-flex(row, center);
      .time{
        opacity: 0.5;
      }
      .message-text{
        @include text-wrap;
        overflow: hidden;
        max-width: 100%;
      }
      /* Very small screens */
      @media screen and (width < $very-small-screen){
        flex-direction: column;
        .message-text{
          padding-block-end: 0.5em;
          order: 2;
        }
        .time{
          text-align: center;
          order: 1;
        }
      }
      /* Medium and large screens */
      @media screen and (width >= $very-small-screen){
        .time{
          margin-inline-start: auto;
          padding-inline-start: 0.5em;
          text-align: end;
        }
      }
    }
  }
</style>
