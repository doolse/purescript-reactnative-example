module Main.Android where

import Prelude
import Control.Monad.Eff (Eff)
import Data.Array (length)
import Data.Function.Eff (mkEffFn1)
import Data.Maybe (Maybe(..))
import Data.Nullable (toMaybe)
import Movie.Data (Route(ShowMovie, Search))
import Movies.MovieScreen (MovieScreenProps(..), movieScreen)
import React (ReactClass, createClass, spec)
import ReactNative.API (REGISTER, registerComponent)
import ReactNative.Android.API (addBackEventCallback)
import ReactNative.Android.Components (toolbarAndroid')
import ReactNative.Components.Navigator (getCurrentRoutes, navigator', pop, sceneConfig, sceneConfigs, sceneRenderer)
import ReactNative.Components.View (view)
import ReactNative.PropTypes (nativeImageSource, refFunc)
import ReactNative.PropTypes.Color (rgbi, white)
import ReactNative.Styles (Styles, backgroundColor, flex, height, staticStyles, styles)
import SearchScreen (searchScreenAndroid)

sheet :: {
    container :: Styles
  , toolbar :: Styles
}
sheet = {
    container: staticStyles [
        flex 1
      , backgroundColor white
    ]
  , toolbar: staticStyles [
      backgroundColor $ rgbi 0xa9a9a9
    , height 56
  ]
}

appAndroid :: ReactClass Unit
appAndroid = createClass $ spec unit render
  where
    render this = pure $ navigator' _
                                  { ref = refFunc $ mkEffFn1 addBackListener
                                    , style = sheet.container
                                    , configureScene = sceneConfig sceneConfigs.fadeAndroid
                                  }
                                  initialRoute
                                  (sceneRenderer routeMapper)
    addBackListener navU = case toMaybe navU of
        Just nav -> addBackEventCallback $ mkEffFn1 \_ ->
                      if (length $ getCurrentRoutes nav) > 1 then pop nav *> pure true
                      else pure false
        _ -> pure unit
    initialRoute = Search
    routeMapper Search nav = searchScreenAndroid {navigator: nav}
    routeMapper (ShowMovie movie) nav  = view (styles [flex 1]) [
      toolbarAndroid' _ {style=sheet.toolbar
        , actions=[]
        , titleColor=white
        , title = movie.title
        , navIcon=nativeImageSource {android:"android_back_white", height:96, width:96}
        , onIconClicked = mkEffFn1 \_ -> pop nav
        } []
    , movieScreen $ MovieScreenProps {movie}
    ]


main :: forall eff. Eff ( register :: REGISTER | eff) Unit
main = registerComponent "reactnativeMovieExample" appAndroid
