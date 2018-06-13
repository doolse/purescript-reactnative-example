module Main where

import Prelude

import Effect (Effect)
import Movies.MovieScreen (movieScreenClass)
import React (ReactClass)
import ReactNative.API (registerComponent)
import ReactNative.Navigation (navAware, route)
import ReactNative.Navigation.Stack (stackNavigator)
import ReactNative.PropTypes.Color (rgbi, white)
import ReactNative.Styles (Styles, backgroundColor, flex, height, staticStyles)
import SearchScreen (searchScreenClass)
import Unsafe.Coerce (unsafeCoerce)

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

navigator :: ReactClass {}
navigator = stackNavigator {headerMode:"none"} (unsafeCoerce {
    "search" : route {screen: navAware searchScreenClass},
    "showMovie" : route {screen: navAware movieScreenClass}
})

    -- navigator' { ref: refFunc $ mkEffFn1 addBackListener
    --                           , style: sheet.container
    --                           , configureScene: sceneConfig sceneConfigs.fadeAndroid
    --                           , initialRoute
    --                           , renderScene: sceneRenderer routeMapper
    --                         }
    -- addBackListener navU = case toMaybe navU of
    --     Just nav -> addBackEventCallback $ mkEffFn1 \_ ->
    --                   if (length $ getCurrentRoutes nav) > 1 then pop nav *> pure true
    --                   else pure false
    --     _ -> pure unit
    -- initialRoute = Search
    -- routeMapper Search nav = searchScreenAndroid {navigator: nav}
    -- routeMapper (ShowMovie movie) nav  = view (styles [flex 1]) [
    --   toolbarAndroid' {style: sheet.toolbar
    --     , actions:[]
    --     , titleColor:white
    --     , title: movie.title
    --     , navIcon: nativeImageSource {android:"android_back_white", height:96, width:96}
    --     , onIconClicked: mkEffFn1 \_ -> pop nav
    --     } []
    -- , movieScreen {movie}
    -- ]


main :: Effect Unit
main = registerComponent "reactnativeMovieExample" navigator
