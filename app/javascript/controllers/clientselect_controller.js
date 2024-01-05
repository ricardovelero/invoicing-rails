import { Controller } from "@hotwired/stimulus";
import { get } from "@rails/request.js";

export default class extends Controller {
  static targets = ["select"];
  static values = {
    url: String,
    param: String,
  };

  connect() {
    if (this.selectTarget.id === "") {
      this.selectTarget.id = Math.random().toString(36);
    }
  }

  change(event) {
    let query = { target: this.selectTarget.id };
    query[this.paramValue] = event.target.selectedOptions[0].value;

    // A fix so the locale query parameter doesn't go in the middle
    // Maybe use the locale as a url path is better for future cases
    const url = this.urlValue.replace(/\?locale=[a-zA-Z]{2}/, "");

    get(url + "/" + query[this.paramValue], {
      query: query,
      responseKind: "turbo-stream",
    });
  }
}
