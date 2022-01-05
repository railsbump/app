import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["earlierRailsVersion"]

  toggleEarlierRailsVersions(event) {
    event.preventDefault()
    $(this.earlierRailsVersionTargets).toggle()
    $(event.currentTarget).text(
      $(event.currentTarget).text()
                            .replace(/^(\w+)/, match => match === "Show" ? "Hide" : "Show")
    )
  }
}
