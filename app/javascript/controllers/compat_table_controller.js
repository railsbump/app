import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['checking']

  connect() {
    this.timer = setInterval(() => {
      this.refresh()
    }, 2000)
  }

  refresh() {
    if (!this.checkingTargets.length) {
      this.stopRefresh()
      return
    }

    const compats = this.checkingTargets.slice(0, 10).map(el => [el.dataset.gemmy, el.dataset.railsRelease])
    const params  = new URLSearchParams({ compats: JSON.stringify(compats) })
    const url     = `${this.data.get('url')}?${params.toString()}`

    $.getScript(url)
      .fail((xhr, status, error) => {
        this.stopRefresh()
        if (Rollbar)
          Rollbar.error('Error during compat table refresh.', { xhr: xhr, status: status, error: error })
      })
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
