var cpx = require("cpx");

cpx.copy("dist/lara-typescript.js","../app/assets/javascripts/",{update:true});
cpx.copy("dist/lara-typescript.css","../app/assets/stylesheets/",{update:true});
cpx.copy("dist/example-interactive/index.*","../public/example-interactive/",
         {clean: true, update:true});
