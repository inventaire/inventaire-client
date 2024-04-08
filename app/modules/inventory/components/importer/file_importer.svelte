<script lang="ts">
  import { createEventDispatcher } from 'svelte'
  import dataValidator from '#inventory/lib/data_validator'
  import commonParser from '#inventory/lib/importer/parsers/common'
  import Flash from '#lib/components/flash.svelte'
  import Link from '#lib/components/link.svelte'
  import files_ from '#lib/files'
  import { I18n } from '#user/lib/i18n'

  const dispatch = createEventDispatcher()

  export let importer
  const { name, accept, link, label, format, help, parse, encoding } = importer
  let files, flash

  const getFile = async () => {
    try {
      const data = await files_.readFile('readAsText', files[0], encoding, true)
      dataValidator(importer, data)
      const candidatesData = parse(data).map(commonParser)
      dispatch('createExternalEntries', candidatesData)
      dispatch('createCandidatesQueue')
    } catch (err) {
      flash = err
    }
  }
</script>

<div class="importer-data">
  <p class="importer-name">
    {#if link}
      <Link url={link} title={label} text={label} />
    {:else}
      <span title={label}>{label}</span>
    {/if}
    {#if format && format !== 'all'}
      <span class="format">( .{format} )</span>
    {/if}
  </p>
  {#if help}
    <p>{@html I18n(help)}</p>
  {/if}
</div>

<input
  title={name}
  type="file"
  bind:files
  {accept}
  on:change={getFile}
/>

<Flash bind:state={flash} />

<style lang="scss">
  @import "#modules/general/scss/utils";
  .format{
    padding: 0;
    color: #888;
    font-size: 0.9em;
  }
  .importer-data{
    @include display-flex(row, center);
  }
  .importer-name{
    margin: 0 0.7em;
  }
  input{
    padding: auto 0;
  }
  p{
    :global(a){
      color: #008;
      text-decoration: underline;
    }
  }
</style>
