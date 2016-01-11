(function () {
  var Dropdown = {};

  Dropdown.init = function (dropdown) {
    this.dropdown = dropdown;
    this.toggler = dropdown.querySelector(".dropdown-toggle");
    this.menu = dropdown.querySelector(".dropdown-menu");
    this.toggler.addEventListener("click", this.toggle.bind(this), false);
    this.menu.addEventListener("click", this.close.bind(this), false);
    return this;
  };

  Dropdown.toggle = function (event) {
    if (event) {
      event.preventDefault();
      event.stopPropagation();
    }

    this.menu.style.visibility = "hidden";
    this.dropdown.classList.toggle("open");
    this.toggler.setAttribute("aria-expanded", this.dropdown.classList.contains("open"));

    if (this.dropdown.classList.contains("dropdown-align-right")) {
      this.menu.style.left = (this.dropdown.offsetWidth - this.menu.offsetWidth) + "px";
    }
    this.menu.style.visibility = "visible";
  };

  Dropdown.close = function () {
    this.dropdown.classList.remove("open");
    this.toggler.setAttribute("aria-expanded", false);
  };

  var dropdowns = Array.prototype.map
    .call(document.querySelectorAll(".dropdown"), function (element) {
      return Object.create(Dropdown).init(element);
    });

  function closeAll() {
    dropdowns.forEach(function (dropdown) {
      dropdown.close();
    });
  }

  window.addEventListener("resize", closeAll, false);
  window.addEventListener("orientationchange", closeAll, false);
  document.body.addEventListener("click", closeAll, false);
}());
