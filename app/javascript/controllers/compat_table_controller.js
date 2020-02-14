import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['checking']

  connect() {
    this.timer = setInterval(() => {
      this.refresh()
    }, 1000)
  }

  refresh() {
    if (!this.checkingTargets.length) {
      this.stopRefresh()
      return
    }

    const compats = this.checkingTargets.map(el => [el.dataset.gemmy, el.dataset.railsRelease])
    const params  = new URLSearchParams({ compats: JSON.stringify(compats) })
    const url     = `${this.data.get('url')}?${params.toString()}`

    $.getScript(url)
  }

  stopRefresh() {
    if (this.timer) {
      clearInterval(this.timer)
    }
  }

  disconnect() {
    this.stopRefresh()
  }
}
