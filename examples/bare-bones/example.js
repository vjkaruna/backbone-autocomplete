$(document).ready(function() {
  $('input[type=text]').focus()

  var c = new AutocompleteItems([
    { name: 'wine'          , kind: 'ingredient', token: '#'  } ,
    { name: 'chocolate'     , kind: 'ingredient', token: '#'  } ,
    { name: 'hummus'        , kind: 'ingredient', token: '#'  } ,
    { name: 'cheese'        , kind: 'ingredient', token: '#'  } ,
    { name: 'mountains'     , kind: 'ingredient', token: '#'  } ,
    { name: 'oceans'        , kind: 'ingredient', token: '#'  } ,
    { name: 'down time'     , kind: 'ingredient', token: '#'  } ,

    { name: 'monica'        , kind: 'person'    , token: '@'  } ,
    { name: 'piggly'        , kind: 'person'    , token: '@'  } ,

    { name: 'san francisco' , kind: 'place'     , token: '[]' } ,
    { name: 'cupertino'     , kind: 'place'     , token: '[]' } ,
    { name: 'palo alto'     , kind: 'place'     , token: '[]' } ,
    { name: 'san mateo'     , kind: 'place'     , token: '[]' } ,

    // special characters
    { name: '"double'       , kind: 'weird'     , token: '!'  } ,
    { name: '"another"'     , kind: 'weird'     , token: '!'  } ,
    { name: "'single"       , kind: 'weird'     , token: '!'  } ,
    { name: "'another'"     , kind: 'weird'     , token: '!'  } ,
    { name: "(O_o)"         , kind: 'weird'     , token: '!'  } ,
    { name: "{O_o}"         , kind: 'weird'     , token: '!'  } ,
    { name: "[O_o]"         , kind: 'weird'     , token: '!'  } ,
    { name: "$$$"           , kind: 'weird'     , token: '!'  } ,
    { name: "^_^"           , kind: 'weird'     , token: '!'  } ,
    { name: "with.a.dot"    , kind: 'weird'     , token: '!'  } ,
    { name: "*"             , kind: 'weird'     , token: '!'  } ,
    { name: "?questions?"   , kind: 'weird'     , token: '!'  } ,

    // without many options
    { name: 'cute' },
    { name: 'panda' },
    { name: 'bear'  }
  ])
  var v = window.v = new AutocompleteItemsView({
    el: $('.autocomplete'),
    collection: c
  });
});