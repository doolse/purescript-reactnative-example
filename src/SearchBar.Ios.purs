module Movie.SearchBar.Ios where

import Prelude
import Dispatcher.React (ReactProps(..), createComponent)
import Movie.SearchBar (SearchBarProps)
import React (ReactClass, ReactElement, createElement)
import ReactNative.Components.ActivityIndicator (activityIndicator', large)
import ReactNative.Components.TextInput (autoCapitalize, textInput')
import ReactNative.Components.View (view)
import ReactNative.PropTypes (center, unsafeRef)
import ReactNative.Styles (Styles, flex, height, marginTop, padding, paddingLeft, staticStyles, width)
import ReactNative.Styles.Flex (alignItems, flexDirection, row)
import ReactNative.Styles.Text (fontSize)

searchBarClass :: forall eff. ReactClass (SearchBarProps eff)
searchBarClass = createComponent unit render unit
  where
    render _ (ReactProps p) = view sheet.searchBar [
      textInput' _ {
        ref = unsafeRef "input"
      , autoCapitalize = autoCapitalize.none
      , onChange = p.onSearchChange
      , placeholder =  "Search a movie..."
      , onFocus = p.onFocus
      , style = sheet.searchBarInput
      }
    , activityIndicator' _ {size=large, style=sheet.spinner} p.isLoading
    ]

searchBar :: forall eff. SearchBarProps eff -> ReactElement
searchBar p = createElement searchBarClass p []

sheet :: {
    searchBar :: Styles
  , searchBarInput :: Styles
  , spinner :: Styles
}
sheet = {
  searchBar: staticStyles [
      marginTop 64
    , padding 3
    , paddingLeft 8
    , flexDirection row
    , alignItems center
  ],
  searchBarInput: staticStyles [
      fontSize 15
    , flex 1
    , height 30
  ],
  spinner: staticStyles [
      width 30
  ]
}
