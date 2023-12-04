<script>
  import { onChange } from '#lib/svelte/svelte'
  import Message from '#transactions/components/message.svelte'
  import { buildTimeline } from '#transactions/lib/transactions'
  import Action from '#transactions/components/action.svelte'

  export let transaction

  let timeline = []
  function updateTimeline () {
    timeline = buildTimeline(transaction)
  }

  $: if (transaction.messages) onChange(transaction.actions, transaction.messages, updateTimeline)
</script>

<div class="timeline">
  {#each timeline as event}
    {#if event.message}
      <Message messageDoc={event} {transaction} />
    {:else}
      <Action action={event} {transaction} />
    {/if}
  {/each}
</div>

<style lang="scss">
  @import '#general/scss/utils';
  $timeline-bar-color: #bbb;

  .timeline{
    margin-block-end: 1em;

    // timeline vertical bar
    position: relative;
    &::before{
      display: block;
      content: "";
      position: absolute;
      margin-inline-start: 1.2em;
      width: 1px;
      height: 100%;
      background-color: $timeline-bar-color;
      z-index: 1;
    }

    /* Small screens */
    @media screen and (max-width: $very-small-screen){
      padding-inline-start: 0.4em;
      padding-inline-end: 0.2em;
      max-width: 100%;
      overflow: hidden;
    }
    /* Large screens */
    @media screen and (min-width: $very-small-screen){
      padding-inline-start: 1.2em;
      padding-inline-end: 1em;
    }
  }
</style>
