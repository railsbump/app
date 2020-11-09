import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['earlierVersion']

  toggleEarlierVersions(event) {
    event.preventDefault()
    $(this.earlierVersionTargets).toggle()
    $(event.currentTarget).text(
      $(event.currentTarget).text()
                           .replace(/^(\w+)/, match => match === 'Show' ? 'Hide' : 'Show')
    )
  }
}
