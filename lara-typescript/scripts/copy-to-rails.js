var cpx = require("cpx");

cpx.copy("dist/lara-typescript.js","../app/assets/javascripts/",{update:true});
cpx.copy("dist/lara-typescript.css","../app/assets/stylesheets/",{update:true});
cpx.copy("dist/example-interactives/index.*","../public/example-interactives/",
         {clean: true, update:true});
