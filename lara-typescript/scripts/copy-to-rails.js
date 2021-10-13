var cpx = require("cpx");
var rimraf = require("rimraf");

cpx.copy("dist/lara-typescript.js","../app/assets/javascripts/",{update:true});
cpx.copy("dist/lara-typescript.css","../app/assets/stylesheets/",{update:true});
cpx.copy("dist/example-interactives/**/*.*","../public/example-interactives/", {clean: true, update:true});

/* remove typescript .d.ts files */
rimraf.sync("dist/example-interactives/src/**/*.*");
