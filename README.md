backbone-autocomplete
=====================

TODO

* api to change autocomplete input field
* unit tests
* fix TODOS
* organize code properly - methods don't work unless `bare` is run on coffee's build
* update docs to better explain how to use each method
* add package.json

A progressively enhanced autocomplete field powered by backbone.js and underscore.js

## Overview

html:

    <div class="autocomplete">
      <form action="/search">
        <input type="text" placeholder="Search...">
        <ul class="autocomplete-results" style="display: none"></ul>
      </form>
    </div>

coffee:

    document.ready ->
      c = new AutocompleteItems [
        { name: 'apple'   , kind: 'fruit'    , token: '#' },
        { name: 'orange'  , kind: 'fruit'    , token: '#' },
        { name: 'carrot'  , kind: 'vegetable', token: '@' },
        { name: 'broccoli', kind: 'vegetable', token: '@' },
      ]
      v = new AutocompleteView
        el: $('input.autocomplete')
        collection: c

## Options

### Required

* `el`: an element containing a `input[type=text]` field
* `collection`: a `AutocompleteItems` collection

#### Optional

* `itemView`: a subclass of `AutocompleteItemView` if you need custom behavior

## Methods

* `submit()`

  * submits the parent form. if needed, finishes autocomplete from selected
    result

* `showResults()`

  * shows autocomplete results

* `hideResults()`

  * hides autocomplete results

* `selectResult(index = 0)`

  * selects the autocomplete item at the given index. does not submit the form.

## Behavior

* typing or copy/paste into the field shows autocomplete results
  * each autocomplete result shows matching substrings within <em></em> tags
* clearing the input field hides autocomplete results
* cycle through autocomplete results with mouse hover or up/down arrow keypress
* select an autocomplete result with mouse click or enter keypress
  * selecting also submits the form containing the autocomplete field
* after submit, the field blurs and autocomplete results are hidden

## Building
You'll need Coffeescript to build

    npm install -g coffee-script

### Source
This will generate a `.js` from the source

    cake build

### Docs

#### Dependencies: Coffeescript & Docco
You'll also need docco to build the docs

    npm install -g docco

#### Building

    cake docs
