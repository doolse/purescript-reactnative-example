module Main.Ios where

import Prelude
import Control.Monad.Eff (Eff)
import React (ReactClass, createClass, spec)
import ReactNative.API (REGISTER, registerComponent)
import ReactNative.Components.NavigatorIOS (navigatorIOS')
import ReactNative.PropTypes.Color (white)
import ReactNative.Styles (Styles, backgroundColor, flex, staticStyles)
import SearchScreen (searchScreenIos)

sheet :: {
  container :: Styles
}
sheet = {
    container: staticStyles [
        flex 1
      , backgroundColor white
    ]
}

appIos :: ReactClass Unit
appIos = createClass $ spec unit render
  where
    render this = pure $ navigatorIOS' _{style = sheet.container} initialRoute
    initialRoute = {
      title: "Movies"
      , component: searchScreenIos
    }

main :: forall eff. Eff ( register :: REGISTER | eff) Unit
main = registerComponent "reactnativeMovieExample" appIos
