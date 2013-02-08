// Generated by CoffeeScript 1.4.0
(function() {
  var AutocompleteItem, AutocompleteItemView, AutocompleteItems, AutocompleteItemsView,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  RegExp.escape = function(s) {
    return s.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&');
  };

  AutocompleteItem = (function(_super) {

    __extends(AutocompleteItem, _super);

    function AutocompleteItem() {
      return AutocompleteItem.__super__.constructor.apply(this, arguments);
    }

    AutocompleteItem.prototype.key = function() {
      return 'name';
    };

    AutocompleteItem.prototype.matches = function(regexp) {
      return regexp.test(this.completion());
    };

    AutocompleteItem.prototype.completion = function() {
      var s;
      s = this.get(this.key());
      if (/\s/.test(s)) {
        s = '"' + s + '"';
      }
      return this._prefixToken() + s + this._suffixToken();
    };

    AutocompleteItem.prototype.groupBy = function() {
      return this.get('kind') || 'results';
    };

    AutocompleteItem.prototype._prefixToken = function() {
      var _ref;
      return ((_ref = this.get('token')) != null ? _ref.slice(0, 1) : void 0) || '';
    };

    AutocompleteItem.prototype._suffixToken = function() {
      var _ref;
      return ((_ref = this.get('token')) != null ? _ref.slice(1, 2) : void 0) || '';
    };

    return AutocompleteItem;

  })(Backbone.Model);

  AutocompleteItems = (function(_super) {

    __extends(AutocompleteItems, _super);

    function AutocompleteItems() {
      return AutocompleteItems.__super__.constructor.apply(this, arguments);
    }

    AutocompleteItems.prototype.model = AutocompleteItem;

    AutocompleteItems.prototype.comparator = function(item) {
      return item.get(item.key()).toLowerCase();
    };

    AutocompleteItems.prototype.matches = function(regexp) {
      return this.filter(function(item) {
        return item.matches(regexp);
      });
    };

    return AutocompleteItems;

  })(Backbone.Collection);

  AutocompleteItemView = (function(_super) {

    __extends(AutocompleteItemView, _super);

    function AutocompleteItemView() {
      return AutocompleteItemView.__super__.constructor.apply(this, arguments);
    }

    AutocompleteItemView.prototype.tagName = 'li';

    AutocompleteItemView.prototype.initialize = function() {
      return this.model.on('change', this.render);
    };

    AutocompleteItemView.prototype.template = function(obj) {
      return "<a href=\"#\">" + obj.markup + "</a>";
    };

    AutocompleteItemView.prototype.render = function(regexp) {
      var completion, json;
      json = this.model.toJSON();
      json.markup = regexp ? json[this.model.key()].replace(regexp, '<em>$1</em>') : json[this.model.key()];
      this.$el.html(this.template(json));
      completion = encodeURIComponent(this.model.completion());
      this.$el.attr('data-autocomplete-completion', completion);
      return this;
    };

    return AutocompleteItemView;

  })(Backbone.View);

  AutocompleteItemsView = (function(_super) {

    __extends(AutocompleteItemsView, _super);

    function AutocompleteItemsView() {
      return AutocompleteItemsView.__super__.constructor.apply(this, arguments);
    }

    AutocompleteItemsView.prototype.itemView = AutocompleteItemView;

    AutocompleteItemsView.prototype.events = {
      'submit form': '_handleSubmit',
      'keyup input[type=text]': '_handleKeypress',
      'focus input[type=text]': 'showResults',
      'blur input[type=text]': 'hideResults',
      'mouseenter [data-autocomplete-completion]': '_selectResult',
      'mousedown [data-autocomplete-completion]': 'submit'
    };

    AutocompleteItemsView.prototype.initialize = function() {
      if (this.options.itemView) {
        this.itemView = this.options.itemView;
      }
      this._$field = this.$el.find('input[type=text]');
      this._$form = this.$el.find('form');
      return this._$resultsList = this.$el.find('.autocomplete-results');
    };

    AutocompleteItemsView.prototype.render = function() {
      return this;
    };

    AutocompleteItemsView.prototype._handleSubmit = function(e, force) {
      var _this = this;
      if (force == null) {
        force = false;
      }
      if (force) {
        return true;
      } else {
        _.delay((function() {
          return _this._$form.trigger('submit', true);
        }), 100);
        return false;
      }
    };

    AutocompleteItemsView.prototype.submit = function() {
      this._finishAutocomplete();
      this.hideResults();
      this._$field.blur();
      return this._handleSubmit(true);
    };

    AutocompleteItemsView.prototype.showResults = function() {
      return this._showAutocompleteResults();
    };

    AutocompleteItemsView.prototype.hideResults = function() {
      return this._$resultsList.hide().empty();
    };

    AutocompleteItemsView.prototype.selectResult = function(i) {
      if (i == null) {
        i = 0;
      }
      return this._$resultsList.children().removeClass('selected').filter(":eq(" + i + ")").addClass('selected');
    };

    AutocompleteItemsView.prototype._selectResult = function(e) {
      var $el;
      $el = $(e.target);
      $el = $el.is('li') ? $el : $el.closest('li');
      return this.selectResult(this._$resultsList.children().index($el));
    };

    AutocompleteItemsView.prototype._handleKeypress = function(e) {
      var _this = this;
      this._debouncedHandleKeypress || (this._debouncedHandleKeypress = _.debounce(function(e) {
        var $el, $first, $items, $last, $selected;
        switch (e.which) {
          case 38:
          case 40:
            $items = _this._$resultsList.children();
            $first = $items.filter(':first-child');
            $last = $items.filter(':last-child');
            $selected = $items.filter('.selected');
            $el = e.which === 38 ? $selected.is(':first-child') ? $last : $selected.prevAll('[data-autocomplete-completion]').filter(':eq(0)') : $selected.is(':last-child') ? $first : $selected.nextAll('[data-autocomplete-completion]').filter(':eq(0)');
            return _this.selectResult($items.index($el));
          case 27:
            return _this.hideResults();
          case 13:
            return _this.submit();
          default:
            return _this._showAutocompleteResults();
        }
      }));
      return this._debouncedHandleKeypress(e);
    };

    AutocompleteItemsView.prototype._showAutocompleteResults = function() {
      var fragment, groups, regexp,
        _this = this;
      this.hideResults();
      if ((fragment = _.last(this._fragments(this._$field.val()))).length > 0) {
        regexp = new RegExp("(" + (RegExp.escape(fragment)) + ")", 'i');
        this._$resultsList.append('<li data-autocomplete-completion="#"><a href="#">See all results</a></li>');
        groups = _.groupBy(this.collection.matches(regexp), function(item) {
          return item.groupBy();
        });
        _.each(groups, function(matches, group) {
          _this._$resultsList.append("<li><h5>" + group + "</h5></li>");
          return _.each(matches, function(item) {
            var v;
            v = new _this.itemView({
              model: item
            });
            return _this._$resultsList.append(v.render(regexp).$el);
          });
        });
        this._$resultsList.show();
        return this.selectResult();
      }
    };

    AutocompleteItemsView.prototype._finishAutocomplete = function() {
      var completion, fragments;
      completion = decodeURIComponent(this._$resultsList.children('.selected').attr('data-autocomplete-completion'));
      if (!_.isEmpty(completion) && completion !== '#') {
        fragments = this._fragments(this._$field.val()).slice(0, -1).concat(completion);
        return this._$field.val(this._fragments(fragments.join(' ')).join(' '));
      }
    };

    AutocompleteItemsView.prototype._fragments = function(s) {
      return _.uniq(s.split(/\s+/));
    };

    return AutocompleteItemsView;

  })(Backbone.View);

}).call(this);
