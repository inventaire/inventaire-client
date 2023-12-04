<script>
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import { userContent } from '#lib/handlebars_helpers/user_content'
  import { getLocalTimeString, timeFromNow } from '#lib/time'

  export let messageDoc

  const { created, message, userDoc } = messageDoc
  const { picture, pathname, username } = userDoc
  const sameUser = app.user.id
</script>

<div class="message">
  <div class="avatar" class:sameUser>
    {#if !sameUser}
      {#if picture}
        <div class="innerAvatar">
          <a href={pathname} class="showUser" title={username}>
            <img src={imgSrc(picture, 36)} alt={username} />
          </a>
        </div>
      {/if}
    {/if}
  </div>
  <div class="rest" class:sameUser>
    <p class="message-text">{@html userContent(message)}</p>
    <p class="time" title={getLocalTimeString(created)}>{timeFromNow(created)}</p>
  </div>
</div>

<style lang="scss">
  @import '#general/scss/utils';
  @import '#transactions/scss/transactions_commons';
  .message{
    @include display-flex(row);
    // Somehow required to make .message-text long words wrap
    overflow: hidden;
    .avatar{
      flex: 0 0 36px;
      &:not(.sameUser){
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
      @include display-flex(row);
      .time{
        opacity: 0.5;
      }
      .message-text{
        @include text-wrap;
        overflow: hidden;
        max-width: 100%;
      }
      /* Small screens */
      @media screen and (max-width: $very-small-screen){
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
      /* Large screens */
      @media screen and (min-width: $very-small-screen){
        .time{
          margin-inline-start: auto;
          padding-inline-start: 0.5em;
          text-align: end;
        }
      }
    }
  }
</style>
