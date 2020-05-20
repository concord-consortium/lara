#! /usr/bin/env node

const replace = require("./replace")

replace(`${__dirname}/docs/lara-plugin-api/`, "../")
replace(`${__dirname}/docs/interactive-api-client/`, "../")