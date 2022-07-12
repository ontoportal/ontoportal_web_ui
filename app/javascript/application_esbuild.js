// Entry point for the build script in your package.json


import * as myMetadata from './../assets/javascripts/bp_metadata';

import { Turbo } from "@hotwired/turbo-rails"
Turbo.session.drive = false
import "./controllers"
import * as bootstrap from "bootstrap"

myMetadata.ChooseMetadata();
window.bootstrap = bootstrap




