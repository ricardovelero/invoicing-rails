import { Application } from "@hotwired/stimulus";
import { Tabs, Toggle } from "tailwindcss-stimulus-components";

const application = Application.start();

application.register("tabs", Tabs);
application.register("toggle", Toggle);

// Configure Stimulus development experience
application.debug = false;
window.Stimulus = application;

export { application };
