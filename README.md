backbone-autocomplete
=====================

TODO

* sections
* special syntax
* form submit
* unit tests
* fix TODOS
* documentation

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
      v = new AutocompleteView
        el: $('input.autocomplete')

## Options

### Required

* `el`: an input[type=text] field
* TODO how to handle input data and/or callback for autocomplete results
* TODO how to handle special syntax: #, @, [], "", ''

### Optional

* `template`: a function that takes an autocomplete item and renders html.

## Properties

* `el`: the input[type=text] field element

## Methods

* `submit()`

  * submits the parent form. if needed, finishes autocomplete from selected
    result
  * triggers `autocomplete:submit`

* `showResults()`

  * shows autocomplete results
  * triggers `autocomplete:show_results`

* `hideResults()`

  * hides autocomplete results
  * triggers `autocomplete:hide_results`

* `selectResult(index = 0)`

  * selects the autocomplete item at the given index. does not submit the form.
  * triggers `autocomplete:select_result`

## Behavior

* typing or copy/paste into the field shows autocomplete results
  * each autocomplete result shows matching substrings within <em></em> tags
* clearing the input field hides autocomplete results
* cycle through autocomplete results with mouse hover or up/down arrow keypress
* select an autocomplete result with mouse click or enter keypress
  * selecting also submits the form containing the autocomplete field
* after submit, the field blurs and autocomplete results are hidden
