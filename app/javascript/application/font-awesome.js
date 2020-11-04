import { config, library, dom } from '@fortawesome/fontawesome-svg-core'

import {
  faThumbsUp          as farThumbsUp,
  faThumbsDown        as farThumbsDown
} from '@fortawesome/pro-regular-svg-icons'

import {
  faSpinner           as fasSpinner
} from '@fortawesome/pro-solid-svg-icons'

// https://fontawesome.com/how-to-use/on-the-web/using-with/turbolinks
config.mutateApproach = 'sync'

library.add(
  // Regular
  farThumbsUp,
  farThumbsDown,

  // Solid
  fasSpinner
)

dom.watch()
