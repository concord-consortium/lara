export function accessibilityClick(event: any) {
  if (event.type === "click") {
    return true;
  }
  else if (event.type === "keydown") {
    const code = event.charCode || event.keyCode;
    if ((code === 32) || (code === 13)) {
      return true;
    }
  }
  else {
    return false;
  }
}
