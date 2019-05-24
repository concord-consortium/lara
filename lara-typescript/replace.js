// adapted from https://github.com/ALMaclaine/replace/blob/master/replace.js
const fs = require("fs");
const path = require("path");

const regex = new RegExp("https://github.com/concord-consortium/lara/blob/([0-9a-f]+)/", "g")

const replace = (file, replacement) => {
  const stats = fs.lstatSync(file);
  if (stats.isSymbolicLink()) {
    return;
  }
  if (stats.isFile()) {
    // console.log(file, replacement);
    let text = fs.readFileSync(file, "utf-8");
    if (text !== null) {
      text = text.replace(regex, replacement);
      fs.writeFileSync(file, text);
    }
  }
  else if (stats.isDirectory()) {
    let files = fs.readdirSync(file);
    for (let i = 0; i < files.length; i++) {
      replace(path.join(file, files[i]), replacement + "../");
    }
  }
}

module.exports = replace;