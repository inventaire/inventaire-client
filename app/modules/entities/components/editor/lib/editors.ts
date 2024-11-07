import type { PropertyDatatype } from '#server/types/property'
import EntityValueDisplay from '../entity_value_display.svelte'
import EntityValueInput from '../entity_value_input.svelte'
import ExternalIdValueDisplay from '../external_id_value_display.svelte'
import FixedStringValueDisplay from '../fixed_string_value_display.svelte'
import ImageValueDisplay from '../image_value_display.svelte'
import ImageValueInput from '../image_value_input.svelte'
import PositiveIntegerValueInput from '../positive_integer_value_input.svelte'
import SimpleDayValueInput from '../simple_day_value_input.svelte'
import StringValueDisplay from '../string_value_display.svelte'
import StringValueInput from '../string_value_input.svelte'
import UrlValueDisplay from '../url_value_display.svelte'
import UrlValueInput from '../url_value_input.svelte'
import type { ComponentType } from 'svelte'

interface EditorConfig {
  InputComponent?: ComponentType
  DisplayComponent: ComponentType
  showSave?: boolean
}

type PseudoPropertyDatatype = 'fixed-string'
type EditorDatatype = Exclude<PropertyDatatype, 'entity-type'> | PseudoPropertyDatatype

export const editors: Record<EditorDatatype, EditorConfig> = {
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
  date: {
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
