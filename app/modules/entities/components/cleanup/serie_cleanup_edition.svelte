<script lang="ts">
  import { createEventDispatcher } from 'svelte'
  import Flash from '#app/lib/components/flash.svelte'
  import { icon } from '#app/lib/icons'
  import { imgSrc } from '#app/lib/image_source'
  import { wait } from '#app/lib/promises'
  import { loadInternalLink } from '#app/lib/utils'
  import Spinner from '#components/spinner.svelte'
  import { updateClaim, type SerializedEntity } from '#entities/lib/entities'
  import type { EntityValue } from '#server/types/entity'
  import { I18n, i18n } from '#user/lib/i18n'
  import WorkPicker from './work_picker.svelte'

  export let edition: SerializedEntity
  export let work: SerializedEntity
  export let allSerieParts: SerializedEntity[]
  export let largeMode: boolean

  const { uri, image, editPathname } = edition
  let showWorkSwitcher = false
  let flash

  const dispatch = createEventDispatcher()

  let changingWork = false
  async function changeEditionWork (targetWork: SerializedEntity) {
    try {
      changingWork = true
      await updateClaim(edition, 'wdt:P629', work.uri as EntityValue, targetWork.uri as EntityValue)
      // This sleep time seems to be required to prevent to leave an edition component on the current work
      await wait(500)
      dispatch('changeEditionWork', targetWork)
    } catch (err) {
      flash = err
    } finally {
      changingWork = false
    }
  }

  let copyingWorkLabel = false
  async function copyWorkLabel () {
    try {
      copyingWorkLabel = true
      const currentTitle = edition.claims['wdt:P1476'][0]
      edition = await updateClaim(edition, 'wdt:P1476', currentTitle, work.label)
    } catch (err) {
      flash = err
    } finally {
      copyingWorkLabel = false
    }
  }
</script>

<li class="serie-cleanup-edition" class:large={largeMode}>
  {#if image.url}
    <div class="left">
      <img
        src={imgSrc(image.url, 500)}
        class="img-zoom-in"
        alt=""
        loading="lazy"
      />
    </div>
  {/if}
  <div class="right">
    <div class="top">
      <span class="label">{edition.title}</span>
      <a
        href={editPathname}
        class="pencil"
        title={i18n('edit data')}
        on:click={loadInternalLink}
      >
        {@html icon('pencil')}
      </a>
    </div>
    <span class="uri">{uri}</span>
    <div class="actions">
      {#if changingWork}
        <Spinner center={true} />
      {:else if showWorkSwitcher}
        <WorkPicker
          {work}
          {allSerieParts}
          on:selectWork={e => changeEditionWork(e.detail)}
          on:close={() => showWorkSwitcher = false}
        />
      {:else}
        <button
          class="toggle-work-picker"
          on:click={() => showWorkSwitcher = !showWorkSwitcher}
        >
          {@html icon('arrows')}
          {I18n("change edition's work")}
        </button>
      {/if}

      {#if copyingWorkLabel}
        <Spinner center={true} />
      {:else if edition.title !== work.label}
        <button class="copy-work-label" title="{I18n('the edition new title would be:')} {work.label}" on:click={copyWorkLabel}>
          {@html icon('copy')}
          <span>{I18n('copy work label')}</span>
        </button>
      {/if}
    </div>
  </div>
  <Flash state={flash} />
</li>

<style lang="scss">
  @use '#general/scss/utils';
  .serie-cleanup-edition{
    padding: 0 0.2em;
    margin: 0.2em 0;
    background-color: white;
    @include display-flex(row, center, center);
    :global(.work-picker){
      margin: 0.5em 0;
      &:not(.hidden){
        @include display-flex(column, center, center);
      }
    }
    &.large{
      flex-direction: column;
      .img-zoom-in{
        max-width: 30em;
      }
    }
  }
  .left{
    flex: 0 0 auto;
    margin-inline-end: 0.2em;
    .img-zoom-in{
      max-width: 7.5em;
    }
  }
  .right{
    flex: 1 0 0;
    margin: 0.5em;
  }
  .top{
    @include display-flex(row);
  }
  .actions{
    margin-block-start: 0.5em;
    padding: 0.5em;
    background-color: #eee;
    @include radius;
    button{
      text-align: start;
    }
  }
  .toggle-work-picker, .copy-work-label{
    display: block;
    margin-block-start: 0.5em;
    :global(.fa){
      font-size: 0.9em;
    }
    @include text-hover(#333);
  }
</style>
