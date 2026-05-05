//
// If there are "prev" or "next" links then let them be keyboard operated
//
document.addEventListener("keydown", function (event) {
  if (event.key === "ArrowLeft") {
    let prevLink = document.querySelector("a[rel='prev']");
    if (prevLink) {
      prevLink.click();
    }
  } else if (event.key === "ArrowRight") {
    let nextLink = document.querySelector("a[rel='next']");
    if (nextLink) {
      nextLink.click();
    }
  }
});
