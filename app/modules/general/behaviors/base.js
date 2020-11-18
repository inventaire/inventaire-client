import General from './general'
import AlertBox from './alertbox'
import AutoFocus from './autofocus'
import Dropdown from './dropdown'
import Loading from './loading'
import SuccessCheck from './success_check'
import TogglePassword from './toggle_password'
import PreventDefault from './prevent_default'
import ElasticTextarea from './elastic_textarea'
import BackupForm from './backup_form'
import Toggler from './toggler'
import DeepLinks from './deep_links'
import Tooltip from './tooltip'
import ClampedExtract from './clamped_extract'
import EntitiesCommons from './entities_commons'
import ImgZoomIn from './img_zoom_in'

const behaviors = {
  General,
  AlertBox,
  AutoFocus,
  Dropdown,
  Loading,
  SuccessCheck,
  TogglePassword,
  PreventDefault,
  ElasticTextarea,
  BackupForm,
  Toggler,
  DeepLinks,
  Tooltip,
  ClampedExtract,
  EntitiesCommons,
  ImgZoomIn,
}

for (const behaviorName in behaviors) {
  behaviors[behaviorName].behaviorName = behaviorName
}

export default {
  initialize () {
    Marionette.Behaviors.behaviorsLookup = () => behaviors
  }
}
