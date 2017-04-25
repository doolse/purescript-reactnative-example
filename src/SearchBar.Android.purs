module Movie.SearchBar.Android where

import Prelude
import Dispatcher (DispatchEffFn(DispatchEffFn), effEval)
import Dispatcher.React (ReactProps(..), createComponent, unsafeWithRef)
import Movie.SearchBar (SearchBarProps)
import React (ReactClass, ReactElement, createElement)
import ReactNative.Components.ActivityIndicator (activityIndicator', large)
import ReactNative.Components.Image (image)
import ReactNative.Components.TextInput (autoCapitalize, focus, textInput')
import ReactNative.Components.TouchableNativeFeedback (TouchableNativeBackground, selectableBackground, selectableBackgroundBorderless, touchableNativeFeedback')
import ReactNative.Components.View (view, view_)
import ReactNative.Platform (platformVersion)
import ReactNative.PropTypes (center, nativeImageSource, unsafeRef)
import ReactNative.PropTypes.Color (rgba, rgbi, transparent, white)
import ReactNative.Styles (Styles, backgroundColor, flex, height, marginHorizontal, marginRight, padding, staticStyles, width)
import ReactNative.Styles.Flex (alignItems, flexDirection, row)
import ReactNative.Styles.Text (bold, color, fontSize, fontWeight)

searchBGColor :: TouchableNativeBackground
searchBGColor = if platformVersion >= 21 then selectableBackgroundBorderless else selectableBackground

searchBarClass :: forall eff. ReactClass (SearchBarProps eff)
searchBarClass = createComponent unit render unit
  where
    render _ (ReactProps p) (DispatchEffFn d) = view sheet.searchBar [
        touchableNativeFeedback' {background:searchBGColor, onPress:d $ effEval $ \_ -> unsafeWithRef focus "input"} $
          view_ [ image sheet.icon $ nativeImageSource {
                  android: "android_search_white",
                  width: 96,
                  height: 96
                } ]
      , textInput' {
          ref: unsafeRef "input"
        , autoCapitalize: autoCapitalize.none
        , autoCorrect: false
        , autoFocus: true
        , onChange: p.onSearchChange
        , placeholder:  "Search a movie..."
        , placeholderTextColor: rgba 255 255 255 0.5
        , onFocus: p.onFocus
        , style: sheet.searchBarInput
        }
      , activityIndicator' {color:white, size:large, style:sheet.spinner, animating: p.isLoading}
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
