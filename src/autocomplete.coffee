## RegExp.escape
#
# Implementation via [StackOverflow](http://stackoverflow.com/questions/3561493/is-there-a-regexp-escape-function-in-javascript/3561711#3561711)

RegExp.escape = (s) -> s.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&')


## AutocompleteItem
#
# NOTE: probably SHOULD BE subclassed by clients
#

class AutocompleteItem extends Backbone.Model

  #### Public

  # Return the JSON property name used to store the object's primary key.
  # Usually, this is a 'name' or 'key'. Subclasses can override this to
  # conform to their own JSON's idiosyncracies.
  key: ->
    'name'

  # Test whether or not this object matches the given regexp. Subclasses
  # can override this to define a different matching algorithm.
  matches: (regexp) ->
    regexp.test(@completion())

  # The completion string for this object, quoted if it contains spaces.
  completion: ->
    s = @get(@key())
    s = '"' + s + '"' if /\s/.test(s)
    @_prefixToken() + s + @_suffixToken()

  # how to group the results
  groupBy: ->
    @get('kind') || 'results'

  #### Private

  # a prefix token, e.g. '[' or '#'
  _prefixToken: ->
    @get('token')?.slice(0, 1) || ''

  # a suffix token, e.g. ']'
  _suffixToken: ->
    @get('token')?.slice(1, 2) || ''


## AutocompleteItems
#
# NOTE: probably doesn't need to be subclassed by clients
#

class AutocompleteItems extends Backbone.Collection

  #### Public

  # a collection of AutocompleteItem objects
  model: AutocompleteItem

  # sort autocomplete items by lowercase key asc
  comparator: (item) ->
    item.get(item.key()).toLowerCase()

  # find autocomplete items matching the given regexp
  matches: (regexp) ->
    @filter((item) -> item.matches(regexp))

  #### Private

  # nothing yet


## AutocompleteItemView
#
# NOTE: probably doesn't need to be subclassed by clients
#

class AutocompleteItemView extends Backbone.View

  #### Public

  # autocomplete items are li elements
  tagName: 'li'

  # initialize
  initialize: ->
    # re-render on model `change` events
    @model.on 'change', @render

  # subclasses should override this template function
  template: (obj) ->
    # TODO should we throw an error instead to force people to subclass?
    # Or get template from AutocompleteItem objects?
    "<a href=\"#\">#{obj.markup}</a>"

  # render the template into @$el
  # TODO this is gross and needs to be re-done, but depends on where
  # @template() ends up living.
  render: (regexp) ->

    # munge some JSON
    json = @model.toJSON()
    json.markup = if regexp
      json[@model.key()].replace(regexp, '<em>$1</em>')
    else
      json[@model.key()]

    # update @$el's html
    @$el.html(@template(json))

    completion = encodeURIComponent(@model.completion())
    @$el.attr('data-autocomplete-completion', completion)

    # return @ per Backbone.View convention
    @

  #### Private

  # nothing yet


## AutocompleteItemsView
#
# NOTE: probably doesn't need to be subclassed by clients
#

class AutocompleteItemsView extends Backbone.View

  #### Public

  # optionally override this with subclasses of AutocompleteItemView
  itemView: AutocompleteItemView

  # events to which autocomplete responds to
  events:
    'submit form'                              : '_handleSubmit'

    # keying into the input field
    'keyup input[type=text]'                   : '_handleKeypress'

    # focusing the input field should autocomplete results
    'focus input[type=text]'                   : 'showResults'

    # blurring the input field hides autocomplete results
    'blur input[type=text]'                    : 'hideResults'

    # hovering over an autocomplete result selects it
    # TODO why can't i use the `hover` event?
    'mouseenter [data-autocomplete-completion]': '_selectResult'

    # clicking on an autocomplete result finishes autocompleting
    # TODO why can't i use the `click` event?
    'mousedown [data-autocomplete-completion]' : 'submit'

  # initializes the autocomplete, and caches a few DOM elements for use later.
  # NOTE you must initialize this view with @$el already attached to the DOM.
  initialize: ->
    @itemView = @options.itemView if @options.itemView
    @_$field = @$el.find('input[type=text]')
    @_$form = @$el.find('form')
    @_$resultsList = @$el.find('.autocomplete-results')

  # render is a no-op because we require the DOM to already contain the
  # needed markup.
  # TODO discuss. should we have this class render markup completely?
  render: ->
    # return @ per Backbone.View convention
    @

  # this is a little tricky, but essentially it only submits the form after
  # giving it enough time to properly populate the input field.
  # TODO this method is kind of a gross hack. better way?
  _handleSubmit: (e, force = false) ->
    if force
      # submit the form if we really, really want to do so
      return true
    else
      # re-trigger the submit after a small amount of time so autocomplete
      # finishes populating the form.
      _.delay((=> @_$form.trigger('submit', true)), 100)

      # return false to prevent form submit
      false

  # finishes autocomplete, hides results, blurs the input, and submits the form
  submit: ->
    # finish autocomplete
    @_finishAutocomplete()

    # hide autocomplete results
    @hideResults()

    # blur the input field
    @_$field.blur()

    # submit the form
    @_handleSubmit(true)

  # shows autocomplete results that match text inside the input field
  showResults: ->
    # show autocomplete results
    @_showAutocompleteResults()

  # hides autocomplete results, also clearing the DOM element containing them
  hideResults: ->
    # hide (and clear) autocomplete results
    @_$resultsList.hide().empty()

  # selects an autocomplete result at the given index
  selectResult: (i = 0) ->
    # clear 'selected' classes, then add it back to the desired result
    @_$resultsList.children().removeClass('selected').filter(":eq(#{i})").addClass('selected')

  #### Private

  # selects an autocomplete result from a given event (usually a mouseenter)
  _selectResult: (e) ->
    $el = $(e.target)

    # TODO kind of a gross hack. why is the event triggering on inner elements?
    # TODO don't hard code to 'li'
    $el = if $el.is('li') then $el else $el.closest('li')

    @selectResult(@_$resultsList.children().index($el))

  # processes keypress events, performing one of the following:
  #
  # * up/down arrow to select an autocomplete result item
  # * escape to hide autocomplete results
  # * enter to finish autocomplete and submit
  # * other keys to match and display autocomplete results
  #
  _handleKeypress: (e) ->
    # memoize a debounced implementation to be invoked later
    @_debouncedHandleKeypress ||= _.debounce (e) =>

      switch e.which

        # up/down arrow selects an autocomplete result
        when 38, 40
          $items = @_$resultsList.children()
          $first = $items.filter(':first-child')
          $last = $items.filter(':last-child')
          $selected = $items.filter('.selected')

          # TODO is the following the most efficient way to do this?
          $el =
            if e.which is 38
              if $selected.is(':first-child')
                $last
              else
                $selected.prevAll('[data-autocomplete-completion]').filter(':eq(0)')
            else
              if $selected.is(':last-child')
                $first
              else
                $selected.nextAll('[data-autocomplete-completion]').filter(':eq(0)')

          @selectResult($items.index($el))

        # escape key hides autocomplete results
        when 27
          @hideResults()

        # enter key finishes autocomplete and submits
        when 13
          @submit()

        # else, show matching autocomplete results
        else
          @_showAutocompleteResults()

    # invoke the debounced version of this method
    @_debouncedHandleKeypress(e)

  # displays matching autocomplete results to the user
  _showAutocompleteResults: ->
    # first, clear out all autocomplete results
    @hideResults()

    # show autocomplete results if the field is non-empty
    # NOTE assume that we're always only autocompleting the *last* fragment
    if (fragment = _.last(@_fieldFragments())).length > 0

      # a regexp to match autocomplete items
      regexp = new RegExp("(#{RegExp.escape(fragment)})", 'i')

      # we want an "all results" link as the first autocomplete result
      # TODO we shouldn't actually use markup here... right?
      # TODO don't hard code to 'li'
      @_$resultsList.append('<li data-autocomplete-completion="#"><a href="#">See all results</a></li>')

      # group autocomplete results
      groups =_.groupBy(@collection.matches(regexp), (item) -> item.groupBy())

      # render grouped autocomplete results to the DOM
      _.each groups, (matches, group) =>
        # TODO don't hard code to 'li'
        @_$resultsList.append("<li><h5>#{group}</h5></li>")

        # iterate over matching results, rendering them to the DOM
        _.each matches, (item) =>

          # TODO if we want to keep it simple and optimize for speed, maybe
          # we should not use a Backbone.View here and instead just have
          # this view do the rendering. Discuss.
          v = new @itemView(model: item)
          @_$resultsList.append(v.render(regexp).$el)

      # show the autocomplete results
      @_$resultsList.show()

      # automatically select the first autocomplete item
      @selectResult()

  # finishes the autocomplete by replacing the typed-in fragment with the
  # full completion in the input field
  _finishAutocomplete: ->
    # the completion of the autocomplete item selected by the user
    completion = decodeURIComponent(@_$resultsList.children('.selected').attr('data-autocomplete-completion'))

    # if there's a completion, update the input field by replacing the last
    # field fragment with the full completion
    if not _.isEmpty(completion) and completion isnt '#'
      # new fragments
      fragments = @_fieldFragments().slice(0, -1).concat(completion)

      # update the field
      @_$field.val(@_fieldFragments(fragments.join(' ')).join(' '))

  # split the input field's text into separate fragments
  _fieldFragments: (s) ->
    s ||= @_$field.val()
    # TODO using /\s+/ doesn't account for quoted multi-word items... maybe OK?
    _.uniq(s.split(/\s+/))
