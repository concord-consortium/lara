'use strict';
const { laraTypescript } = require("./webpack.config");

module.exports = (env, argv) => {
  return [
    laraTypescript()
  ];
};
