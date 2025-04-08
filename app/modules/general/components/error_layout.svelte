<script lang="ts">
  import { icon as iconFn } from '#app/lib/icons'
  import type { ShowErrorOptions } from '#app/modules/redirect'

  export let message: ShowErrorOptions['message'] = null
  export let icon: ShowErrorOptions['icon'] = null
  export let header: ShowErrorOptions['header'] = null
  export let context: ShowErrorOptions['context'] = null
  export let redirection: ShowErrorOptions['redirection'] = null

  function stringify (obj: ShowErrorOptions['context']) {
    if (typeof obj === 'string') return obj
    else return JSON.stringify(obj, null, 2)
  }
</script>

<div class="error-layout">
  <div class="error-box">
    {#if header}
      <h2 class="subheader">
        {#if icon}{@html iconFn(icon)}{/if}
        {header}
      </h2>
    {/if}
    <p>{message}</p>
    {#if context}<pre class="context">{stringify(context)}</pre>{/if}
    {#if redirection}
      <div class="redirection">
        {#if redirection.buttonAction}
          <button class="button radius {redirection.classes}" on:click={redirection.buttonAction}>{redirection.text}</button>
        {/if}
      </div>
    {/if}
  </div>
</div>

<style lang="scss">
  @use '#general/scss/utils';

  .error-layout{
    text-align: center;
    flex: 1 1 auto;
    min-height: 80vh;
    @include display-flex(column, center, center);
  }
  .error-box{
    background-color: white;
    max-width: 50em;
    margin: 1em;
    @include radius;
    .button{
      font-weight: bold;
    }
    .context{
      background-color: $light-grey;
      opacity: 0.8;
      @include radius;
      padding: 1em;
      margin: 1em 0;
      text-align: start;
      font-size: 0.8em;
      overflow: auto;
    }
  }

  /* Very small screens */
  @media screen and (width < $very-small-screen){
    .error-box{
      padding: 1em;
    }
  }

  /* Large screens */
  @media screen and (width >= $very-small-screen){
    .error-layout{
      padding-block-end: 10em;
    }
    .error-box{
      padding: 2em 4em;
      h2{
        width: 100%;
        font-size: 1.6em;
        @include text-wrap(nowrap);
      }
    }
    .redirection{
      padding-block-start: 1em;
    }
  }
</style>
