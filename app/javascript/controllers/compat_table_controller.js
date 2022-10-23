import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["earlierRailsVersion"]

  toggleEarlierRailsVersions(event) {
    event.preventDefault()

    this.earlierRailsVersionTargets.forEach(element =>
      element.classList.toggle("d-none")
    )
    event.target.innerText = event.target.innerText.replace(/^(\w+)/, match => match === "Show" ? "Hide" : "Show")
  }
}
