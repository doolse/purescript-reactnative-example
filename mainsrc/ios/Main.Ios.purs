module Main where

import Prelude
import Control.Monad.Eff (Eff)
import Dispatcher.React (createComponent)
import React (ReactClass)
import ReactNative.API (REGISTER, registerComponent)
import ReactNative.Components.NavigatorIOS (mkRoute, navigatorIOS')
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
appIos = createComponent unit render unit
  where
    render _ = navigatorIOS' _{style = sheet.container} initialRoute
    initialRoute = mkRoute {
      title: "Movies"
      , component: searchScreenIos
      , passProps: {}
    }

main :: forall eff. Eff ( register :: REGISTER | eff) Unit
main = registerComponent "reactnativeMovieExample" appIos
