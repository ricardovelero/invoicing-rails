import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["item", "theHidden", "qty"];

    click(event) {
        let path = event.path || (event.composedPath && event.composedPath());
        let eventId = path[3].id;
        this.itemTargets.forEach((element) => {
            if (element.id == eventId) {
                element.classList.add(
                    "transform",
                    "opacity-0",
                    "transition",
                    "duration-1000"
                );
                setTimeout(() => element.classList.add("hidden"), 800);
            }
        });
        this.theHiddenTargets.forEach((element) => {
            let hiddenId = element.id.match(/\d+/g);
            if (hiddenId == eventId) {
                element.value = true;
            }
        });
        this.qtyTargets.forEach((element) => {
            let qtyId = element.id.match(/\d+/g);
            if (qtyId == eventId) {
                element.value = 0;
            }
        });
    }
}
// Event.composedPath
(function (e, d, w) {
    if (!e.composedPath) {
        e.composedPath = function () {
            if (this.path) {
                return this.path;
            }
            var target = this.target;

            this.path = [];
            while (target.parentNode !== null) {
                this.path.push(target);
                target = target.parentNode;
            }
            this.path.push(d, w);
            return this.path;
        };
    }
})(Event.prototype, document, window);
