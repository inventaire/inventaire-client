<script>
  import commonParser from '#inventory/lib/parsers/common'
  import dataValidator from '#inventory/lib/data_validator'
  import files_ from '#lib/files'
  import Flash from '#lib/components/flash.svelte'
  import { I18n } from '#user/lib/i18n'

  export let importer, createExternalEntries, createCandidatesQueue
  const { name, accept, link, label, format, help, parse, encoding } = importer
  let { files } = importer
  let flash

  const getFile = async () => {
    try {
      const data = await files_.readFile('readAsText', files[0], encoding, true)
      dataValidator(importer, data)
      const candidatesData = parse(data).map(commonParser)
      createExternalEntries(candidatesData)
      createCandidatesQueue()
    } catch (err) {
      flash = err
    }
  }
</script>

<div class="importer-data">
  <p class="importer-name">
    {#if link}
      <a name={label} href={link}>{label}</a>
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
  name="{name}"
  type="file"
  bind:files={files}
  accept="{accept}"
  on:change={getFile}
  />

<Flash bind:state={flash}/>

<style lang="scss">
  @import '#modules/general/scss/utils';
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
    a, :global(a) {
      color: #008;
      text-decoration: underline;
    }
  }
</style>
