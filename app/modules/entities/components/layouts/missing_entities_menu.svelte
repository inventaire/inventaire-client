<script>
  import { I18n, i18n } from '#user/lib/i18n'
  import { icon } from '#lib/handlebars_helpers/icons'
  import { loadInternalLink } from '#lib/utils'
  import { buildPath } from '#lib/location'

  export let waiting, questionText, createButtons

  createButtons.forEach(createButton => {
    const { type, claims } = createButton
    createButton.href = buildPath('/entity/new', { type, claims })
  })
</script>

{#await waiting then}
  <div class="missing-entities">
    <p>{i18n(questionText)}</p>
    <div class="buttons">
      {#each createButtons as createButton}
        <a href={createButton.href} on:click={loadInternalLink} class="tiny-button">
          {@html icon('plus')}
          {I18n(`create a new ${createButton.type}`)}
        </a>
      {/each}
    </div>
  </div>
{/await}

<style lang="scss">
  @import "#general/scss/utils";
  .missing-entities{
    align-self: center;
    margin: 1em auto;
    padding: 0.5em 1em;
    background-color: $off-white;
    text-align: center;
    .tiny-button{
      display: inline-block;
      margin: 0.5em;
    }
  }
</style>
