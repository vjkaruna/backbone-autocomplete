class AutocompleteItem extends Backbone.Model
  key: ->
    'name'

  matches: (regexp) ->
    regexp.test(@get(@key()))

class AutocompleteItems extends Backbone.Collection
  model: AutocompleteItem

  comparator: (item) ->
    item.get(item.key()).toLowerCase()

  matches: (regexp) ->
    @filter((item) -> item.matches(regexp))

class AutocompleteItemView extends Backbone.View
  tagName: 'li'

  initialize: ->
    @model.on 'change', @render

  template: (obj) ->
    "<a href=\"#\">#{obj.markup}</a>"

  render: (regexp) ->
    json = @model.toJSON()
    json.markup = if regexp
      json[@model.key()].replace(regexp, '<em>$1</em>')
    else
      json[@model.key()]
    @$el.html(@template(json))
    @$el.attr('data-autocomplete-completion', @model.get(@model.key()))
    @

class AutocompleteItemsView extends Backbone.View
  events:
    'keyup input[type=text]'              : '_handleKeypress'
    'focus input[type=text]'              : 'showResults'
    'blur input[type=text]'               : 'hideResults'

    # TODO why can't i use hover and click?
    'mouseenter .autocomplete-results > *': '_selectResult'
    'mousedown .autocomplete-results > *'     : '_finishAutocomplete'

  initialize: ->
    @_$field = @$el.find('input[type=text]')
    @_$form = @$el.find('form')
    @_$resultsList = @$el.find('.autocomplete-results')

  submit: ->
    # hide autocomplete results
    @hideResults()

    # blur the input field
    @_$field.blur()

    # submit the form
    @_$form.submit()

  showResults: ->
    # show autocomplete results
    @_showAutocompleteResults()

  hideResults: ->
    # hide (and clear) autocomplete results
    @_$resultsList.hide().empty()

  selectResult: (i = 0) ->
    # clear 'selected' classes, then add it back to the desired result
    @_$resultsList.children().removeClass('selected').filter(":eq(#{i})").addClass('selected')

  _selectResult: (e) ->
    $el = $(e.target)

    # TODO kind of a gross hack. why is the event triggering on inner elements?
    $el = if $el.is('li') then $el else $el.closest('li')

    @selectResult(@_$resultsList.children().index($el))

  _handleKeypress: (e) ->
    @_debouncedHandleKeypress ||= _.debounce (e) =>
      switch e.which
        when 38, 40 # up/down arrow
          $items = @_$resultsList.children()
          $first = $items.filter(':first-child')
          $last = $items.filter(':last-child')
          $selected = $items.filter('.selected')
          $el = if e.which is 38
            if $selected.is(':first-child') then $last else $selected.prev()
          else
            if $selected.is(':last-child') then $first else $selected.next()
          @selectResult($items.index($el))
        when 27 # escape
          @hideResults()
        when 13 # enter
          @_finishAutocomplete()
        else
          @_showAutocompleteResults(e)

    @_debouncedHandleKeypress(e)

  _showAutocompleteResults: ->
    # first, clear out all autocomplete results
    @hideResults()

    # show autocomplete results if the field is non-empty
    # NOTE assume that we're always only autocompleting the *last* fragment
    if (fragment = _.last(@_fieldFragments())).length > 0

      # a regexp to match autocomplete items
      # TODO we probably need to escape regexp characters from fragment
      regexp = new RegExp("(#{fragment})", 'i')

      # we want an "all results" link as the first autocomplete result
      # TODO we shouldn't actually use markup here... right?
      @_$resultsList.append('<li><a href="#">See all results</a></li>')

      # iterate over matching autocomplete items, rendering them
      _.each @collection.matches(regexp), (item) =>
        v = new AutocompleteItemView(model: item)
        @_$resultsList.append(v.render(regexp).$el)

      # automatically select the first autocomplete item
      @_$resultsList.show().children(':first-child').addClass('selected')

  _finishAutocomplete: ->
    # the completion of the autocomplete item selected by the user
    completion = @_$resultsList.children('.selected').attr('data-autocomplete-completion')

    # update the input field by replacing the last field fragment with the
    # full completion
    unless _.isEmpty(completion)
      fragments = @_fieldFragments().slice(0, -1).concat(completion)
      @_$field.val(fragments.join(' '))

    # submit the parent form
    @submit()

  _fieldFragments: ->
    @_$field.val().split(/\s+/)
