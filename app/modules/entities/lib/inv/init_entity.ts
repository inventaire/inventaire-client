export default function (attrs) {
  const { _id } = attrs
  const pathname = this.get('pathname')

  this.set({
    aliases: {},
    isInvEntity: true,
    // Always setting the invUri as long as some inv entities
    // use an alternative uri format (namely isbn: uris)
    invUri: `inv:${_id}`,
    history: `${pathname}/history`,
  })

  return this
}
