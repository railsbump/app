import { config, library, dom } from '@fortawesome/fontawesome-svg-core'

import { fas as fs } from '@fortawesome/free-solid-svg-icons'
import { far as fr } from '@fortawesome/free-regular-svg-icons'
import { fab as fb } from '@fortawesome/free-brands-svg-icons'
import { fas as ps } from '@fortawesome/pro-solid-svg-icons'
import { far as pr } from '@fortawesome/pro-regular-svg-icons'
import { fal as pl } from '@fortawesome/pro-light-svg-icons'
import { fad as pd } from '@fortawesome/pro-duotone-svg-icons'

// https://fontawesome.com/how-to-use/on-the-web/using-with/turbolinks
config.mutateApproach = 'sync'

library.add(fs, fr, fb, ps, pr, pl, pd)

dom.watch()
