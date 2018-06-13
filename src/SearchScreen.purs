module SearchScreen where

import Prelude

import Control.Monad.Reader (runReaderT)
import Control.Monad.Writer.Trans (lift)
import Data.Either (either)
import Data.Function.Uncurried (mkFn3)
import Data.Maybe (Maybe(Just, Nothing), maybe)
import Data.Time.Duration (Milliseconds(..))
import Dispatcher (Dispatch1(..), affAction, mkDispatch1)
import Dispatcher.React (getProps, getState, modifyState, renderer, saveRef, withRef)
import Effect (Effect)
import Effect.Aff (Fiber, delay, error, forkAff, killFiber)
import Effect.Class (liftEffect)
import Effect.Ref (new)
import Movie.Data (MovieDetails, OMDBMovie, loadDetails, searchOMDB, unwrapMovie)
import Movie.SearchBar (SearchBarProps)
import Movie.SearchBar.Android (searchBar) as SearchBarAndroid
import Movie.SearchBar.Ios (searchBar) as SearchBarIos
import Movies.MovieCell (movieCell)
import React (ReactClass, ReactElement, component)
import ReactNative.API (alert, keyboardDismiss)
import ReactNative.Components.ListView (ListViewDataSource, cloneWithRows, getRowCount, listView', listViewDataSource, rowRenderer')
import ReactNative.Components.ScrollView (keyboardDismissMode, keyboardShouldPersistTaps, scrollTo)
import ReactNative.Components.Text (text)
import ReactNative.Components.View (view, view')
import ReactNative.Navigation (Navigation, navigate)
import ReactNative.Platform (platformOS, Platform(..))
import ReactNative.PropTypes (center)
import ReactNative.PropTypes.Color (rgba, rgbi, white)
import ReactNative.Styles (Styles, backgroundColor, flex, height, marginLeft, marginTop, marginVertical, opacity, staticStyles, styles')
import ReactNative.Styles.Flex (alignItems)
import ReactNative.Styles.Text (color)

type MyMovie = OMDBMovie
type State = {
    isLoading:: Boolean
  , isLoadingTail:: Boolean
  , dataSource:: ListViewDataSource MyMovie 
  , filter:: String
  , queryNumber:: Int
  , running :: Maybe (Fiber Unit)
}

data Action = Search String | Select MyMovie | ScrollTop

initialState :: State
initialState = {
    isLoading:false
  , running: Nothing
  , isLoadingTail:false
  , dataSource: listViewDataSource []
  , filter: ""
  , queryNumber: 0
}

searchScreenClass :: ReactClass { navigation :: Navigation {movie::Maybe MovieDetails} }
searchScreenClass = component "SearchScreen" spec 
  where
    spec this = do 
      listViewRef <- new Nothing
      let eval (ScrollTop) = do 
            withRef listViewRef (liftEffect <<< scrollTo {x:0, y:0})
          eval (Search q) = do
            {running} <- getState
            newc <- lift $ forkAff do
              delay (Milliseconds 200.0)
              runReaderT doSearch this
            modifyState _{running=Just newc}
            lift $ maybe (pure unit) (killFiber (error "")) running
            where
              doSearch = do
                  modifyState _ {isLoading=true, filter=q, dataSource=listViewDataSource []}
                  result <- lift $ searchOMDB q
                  either (\msg -> do
                            modifyState \s -> s { dataSource=listViewDataSource []
                                                ,isLoading=false }
                            liftEffect <<< alert "Error " $ Just msg
                            )
                        (\movies -> do
                            modifyState \s -> s { dataSource=cloneWithRows s.dataSource movies
                                                  , isLoading=false}
                          )
                        result

          eval (Select m) = do
            liftEffect $ keyboardDismiss
            {navigation} <- getProps
            let gotoMovieDetail movieData = liftEffect $ pushRoute navigation movieData
            result <- lift $ loadDetails m
            either alert' gotoMovieDetail result
            where
              alert' msg =
                liftEffect <<< alert "Error " $ Just msg
          de = affAction this <<< eval
          (Dispatch1 d) = mkDispatch1 de
          render {state: s@{isLoading}} = view sheet.container [
            searchBarViewByPlatform platformOS $ {
                  onSearchChange: d $ Search <<< _.nativeEvent.text
                , onFocus: d \_ -> ScrollTop
                , isLoading }

            , view sheet.separator []
            , if getRowCount s.dataSource == 0 then noMovies else listView' { ref: saveRef listViewRef 
                , renderSeparator: mkFn3 renderSeparator
                , renderFooter: \_ -> renderFooter
                -- , onEndReached=onEndReached
                -- , automaticallyAdjustContentInsets=false
                , keyboardDismissMode: keyboardDismissMode.onDrag
                , keyboardShouldPersistTaps: keyboardShouldPersistTaps.always
                , showsVerticalScrollIndicator: false
                , dataSource: s.dataSource
                , renderRow: rowRenderer' renderRow
              }
            ]
            where
              renderRow m _ _ _ = movieCell (unwrapMovie m) {onSelect: d \_ -> Select m}
              noMovies = view (styles' [sheet.container, sheet.centerText]) [ text sheet.noMoviesText movieText ]
                where movieText = if s.filter == "" then "No movies found"
                                  else if s.isLoading then "" else "No results for \"" <> s.filter <> "\""
      pure {render: renderer render this, state: initialState, componentDidMount: de $ Search "indiana jones" }

    searchBarViewByPlatform :: Platform -> SearchBarProps -> ReactElement
    searchBarViewByPlatform IOS = SearchBarIos.searchBar
    searchBarViewByPlatform Android = SearchBarAndroid.searchBar


    renderSeparator s r h = let style = if h then styles' [ sheet.rowSeparator, sheet.rowSeparatorHide ] else sheet.rowSeparator
      in view' {key:"SEP_" <> s <> r, style} []

    renderFooter = view sheet.scrollSpinner []


pushRoute :: Navigation {movie::Maybe MovieDetails} -> MovieDetails -> Effect Unit
pushRoute n md = navigate n "showMovie" {movie: Just md}

sheet :: { container :: Styles
, centerText :: Styles
, noMoviesText :: Styles
, separator :: Styles
, scrollSpinner :: Styles
, rowSeparator :: Styles
, rowSeparatorHide :: Styles
}
sheet = {
    container: staticStyles [
      flex 1
    , backgroundColor white
    ]
  , centerText: staticStyles [
      alignItems center
    ]
  , noMoviesText: staticStyles [
      marginTop 80
    , color $ rgbi 0x888888
    ]
  , separator: staticStyles [
      height 1
    , backgroundColor $ rgbi 0xeeeeee
    ]
  , scrollSpinner: staticStyles [
      marginVertical 20
    ]
  , rowSeparator: staticStyles [
      backgroundColor $ rgba 0 0 0 0.1
    , height 1
    , marginLeft 4
    ]
  , rowSeparatorHide: staticStyles [
    opacity 0.0
  ]
}
