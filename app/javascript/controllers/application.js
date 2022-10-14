import { Application } from "@hotwired/stimulus";
import { Dropdown, Tabs } from "tailwindcss-stimulus-components";

const application = Application.start();

application.register("dropdown", Dropdown);
application.register('tabs', Tabs);

// Configure Stimulus development experience
application.debug = false;
window.Stimulus = application;

export { application };
