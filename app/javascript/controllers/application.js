import { Application } from "@hotwired/stimulus";
import { Alert, Tabs, Toggle } from "tailwindcss-stimulus-components";

const application = Application.start();

application.register("alert", Alert);
application.register("tabs", Tabs);
application.register("toggle", Toggle);

// Configure Stimulus development experience
application.debug = false;
window.Stimulus = application;

export { application };
