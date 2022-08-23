import EntityValueInput from '../entity_value_input.svelte'
import EntityValueDisplay from '../entity_value_display.svelte'
import StringValueInput from '../string_value_input.svelte'
import StringValueDisplay from '../string_value_display.svelte'
import UrlValueInput from '../url_value_input.svelte'
import UrlValueDisplay from '../url_value_display.svelte'
import FixedStringValueDisplay from '../fixed_string_value_display.svelte'
import SimpleDayValueInput from '../simple_day_value_input.svelte'
import PositiveIntegerValueInput from '../positive_integer_value_input.svelte'
import ImageValueInput from '../image_value_input.svelte'
import ImageValueDisplay from '../image_value_display.svelte'
import ExternalIdValueDisplay from '../external_id_value_display.svelte'

export const editors = {
  entity: {
    InputComponent: EntityValueInput,
    DisplayComponent: EntityValueDisplay,
    showSave: false,
  },
  string: {
    InputComponent: StringValueInput,
    DisplayComponent: StringValueDisplay,
  },
  'external-id': {
    InputComponent: StringValueInput,
    DisplayComponent: ExternalIdValueDisplay,
  },
  url: {
    InputComponent: UrlValueInput,
    DisplayComponent: UrlValueDisplay,
  },
  'fixed-string': {
    // InputComponent: FixedStringValue,
    DisplayComponent: FixedStringValueDisplay,
  },
  'simple-day': {
    InputComponent: SimpleDayValueInput,
    DisplayComponent: StringValueDisplay,
  },
  'positive-integer': {
    InputComponent: PositiveIntegerValueInput,
    DisplayComponent: StringValueDisplay,
  },
  'positive-integer-string': {
    InputComponent: PositiveIntegerValueInput,
    DisplayComponent: StringValueDisplay,
  },
  image: {
    InputComponent: ImageValueInput,
    DisplayComponent: ImageValueDisplay,
  },
}
