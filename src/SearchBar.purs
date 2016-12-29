module Movie.SearchBar where

import Prelude
import React (ReactClass, ReactElement, createClass, createElement, spec)
import React.SimpleAction (handleEff, propsRenderer, unsafeWithRef)
import ReactNative.Components.ActivityIndicator (activityIndicator', large)
import ReactNative.Components.Image (image)
import ReactNative.Components.TextInput (autoCapitalize, focus, textInput')
import ReactNative.Components.Touchable (TouchableNativeBackground, selectableBackground, selectableBackgroundBorderless, touchableNativeFeedback')
import ReactNative.Components.View (view, view_)
import ReactNative.Events (TextInputEvent, EventHandler)
import ReactNative.Platform (platformVersion)
import ReactNative.PropTypes (center, nativeImageSource, unsafeRef)
import ReactNative.PropTypes.Color (rgba, rgbi, transparent, white)
import ReactNative.Styles (Styles, backgroundColor, flex, height, marginHorizontal, marginRight, padding, staticStyles, width)
import ReactNative.Styles.Flex (alignItems, flexDirection, row)
import ReactNative.Styles.Text (bold, color, fontSize, fontWeight)

type SearchBarProps eff = {
    onSearchChange :: EventHandler eff TextInputEvent
  , onFocus :: EventHandler eff TextInputEvent
  , isLoading :: Boolean
}
data Action = Focus

searchBGColor :: TouchableNativeBackground
searchBGColor = if platformVersion >= 21 then selectableBackgroundBorderless else selectableBackground

searchBarClass :: forall eff. ReactClass (SearchBarProps eff)
searchBarClass = createClass $ spec unit $ propsRenderer render
  where
    render t p = view sheet.searchBar [
        touchableNativeFeedback' _ {background=searchBGColor, onPress=handleEff t $ \_ -> unsafeWithRef focus "input"} $
          view_ [ image sheet.icon $ nativeImageSource {
                  android: "android_search_white",
                  width: 96,
                  height: 96
                } ]
      , textInput' _ {
          ref = unsafeRef "input"
        , autoCapitalize = autoCapitalize.none
        , autoCorrect = false
        , autoFocus = true
        , onChange = p.onSearchChange
        , placeholder =  "Search a movie..."
        , placeholderTextColor = rgba 255 255 255 0.5
        , onFocus = p.onFocus
        , style = sheet.searchBarInput
        }
      , activityIndicator' _ {color=white, size=large, style=sheet.spinner} p.isLoading
      ]

searchBar :: forall eff. SearchBarProps eff -> ReactElement
searchBar p = createElement searchBarClass p []

sheet :: { searchBar :: Styles
, searchBarInput :: Styles
, spinner :: Styles
, icon :: Styles
}
sheet = {
  searchBar: staticStyles [
    flexDirection row,
    alignItems center,
    backgroundColor $ rgbi 0xa9a9a9,
    height 56
  ],
  searchBarInput: staticStyles [
    flex 1,
    fontSize 20,
    fontWeight bold,
    color white,
    height 50,
    padding 0,
    backgroundColor transparent
  ],
  spinner: staticStyles [
    width 30,
    height 30,
    marginRight 16
  ],
  icon: staticStyles [
    width 24,
    height 24,
    marginHorizontal 8
  ]
}
