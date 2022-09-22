import error_ from '#lib/error'
import { getColorHexCodeFromModelId, getColorSquareDataUri } from '#lib/images'
import { getVisibilitySummary, getVisibilitySummaryLabel, visibilitySummariesData } from '#general/lib/visibility'

export default Backbone.Model.extend({
  initialize (attrs) {
    const { name } = attrs

    if (name == null) throw error_.new('invalid shelf', 500, attrs)

    const pathname = `/shelves/${attrs._id}`

    this.set({
      pathname,
      inventoryPathname: pathname,
      type: 'shelf'
    })

    if (this.get('color') == null) {
      const colorHexCode = getColorHexCodeFromModelId(this.get('_id'))
      this.set('color', colorHexCode)
    }
    this.setDerivedAttributes()
    this.on('change', this.setDerivedAttributes.bind(this))
  },

  setDerivedAttributes () {
    // The visibility is only known for the main user's shelves
    const visibility = this.get('visibility')
    if (visibility != null) {
      const visibilitySummary = getVisibilitySummary(visibility)
      const visibilitySummaryData = visibilitySummariesData[visibilitySummary]
      this.set({
        icon: visibilitySummaryData.icon,
        label: getVisibilitySummaryLabel(visibility)
      })
    }

    this.set('picture', getColorSquareDataUri(this.get('color')))
  },

  updateMetadata () {
    return {
      title: this.get('name'),
      description: this.get('description'),
      image: this.get('picture'),
      url: this.get('pathname'),
      rss: this.getRss(),
    }
  },

  getRss () { return app.API.feeds('shelf', this.id) },
})
