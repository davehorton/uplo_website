(function() {
  var _this = this;

  window.Mask = (function() {

    function Mask() {
      var _this = this;
      this.hide = function() {
        return Mask.prototype.hide.apply(_this, arguments);
      };
      this.show = function() {
        return Mask.prototype.show.apply(_this, arguments);
      };
      this.htmlElement = document.createElement("div");
      this.htmlElement.classList.add("mask");
      $("body").append(this.htmlElement);
    }

    Mask.prototype.show = function() {
      return this.htmlElement.classList.add("display");
    };

    Mask.prototype.hide = function() {
      return this.htmlElement.classList.remove("display");
    };

    return Mask;

  })();

  window.Popup = (function() {

    function Popup(options) {
      var buttons, content, title,
        _this = this;
      if (options == null) {
        options = {
          id: "",
          title: "",
          text: "",
          css: {},
          buttons: {}
        };
      }
      this.close = function() {
        return Popup.prototype.close.apply(_this, arguments);
      };
      this.hide = function() {
        return Popup.prototype.hide.apply(_this, arguments);
      };
      this.show = function() {
        return Popup.prototype.show.apply(_this, arguments);
      };
      this.setPosition = function(top, left) {
        return Popup.prototype.setPosition.apply(_this, arguments);
      };
      this.htmlElement = document.createElement("div");
      this.htmlElement.classList.add("popup");
      this.htmlElement.classList.add("round-box");
      this.htmlElement.classList.add("blue-gradient-reverse");
      if (options.id !== null && options.id !== void 0) {
        this.htmlElement.id = options.id;
      }
      title = document.createElement("div");
      title.classList.add("title");
      if (options.title === null || options.title === void 0) {
        title.innerHTML = "&nbsp;";
        title.classList.add("non-text");
      } else if ($.browser.msie === true) {
        title.innerText = options.title;
      } else {
        title.textContent = options.title;
      }
      content = this.initContent(options.text, options.css);
      buttons = this.initButtons(options.buttons);
      this.htmlElement.appendChild(title);
      this.htmlElement.appendChild(content);
      this.htmlElement.appendChild(buttons);
      $("body").append(this.htmlElement);
    }

    Popup.prototype.initContent = function(text, css) {
      var content, tmp;
      if (text == null) {
        text = "";
      }
      if (css == null) {
        css = {};
      }
      content = document.createElement("div");
      content.classList.add("content");
      if ($.browser.msie === true) {
        content.innerText = text;
      } else {
        content.textContent = text;
      }
      if (css === null || css === void 0) {
        this.setPosition();
      } else {
        this.setPosition(css.top, css.left);
        delete css.top;
        delete css.left;
        tmp = $(content);
        $.each(css, function(key, val) {
          return tmp.css(key, val);
        });
      }
      return content;
    };

    Popup.prototype.initButtons = function(buttons) {
      var buttons_pane;
      buttons_pane = document.createElement("div");
      buttons_pane.classList.add("buttons");
      $.each(buttons, function(name, func) {
        var btn;
        btn = document.createElement("button");
        btn.type = "button";
        btn.innerHTML = name;
        $(btn).click(func);
        return buttons_pane.appendChild(btn);
      });
      return buttons_pane;
    };

    Popup.prototype.setPosition = function(top, left) {
      var elm;
      elm = $(this.htmlElement);
      if (top !== null && top !== void 0) {
        elm.css("top", top);
      } else {
        top = $("body").height() - $(this.htmlElement).height();
        top = top / 2;
        elm.css("top", top);
      }
      if (left !== null && left !== void 0) {
        return elm.css("left", left);
      } else {
        left = $("body").width() - $(this.htmlElement).width();
        left = left / 2;
        return elm.css("left", left);
      }
    };

    Popup.prototype.show = function() {
      this.setPosition();
      this.htmlElement.classList.add("display");
      if (!window.mask) {
        window.mask = new Mask();
      }
      return window.mask.show();
    };

    Popup.prototype.hide = function() {
      this.htmlElement.classList.remove("display");
      return window.mask.hide();
    };

    Popup.prototype.close = function() {
      $(this.htmlElement).remove();
      $(".mask").remove();
      return window.mask = null;
    };

    return Popup;

  })();

}).call(this);