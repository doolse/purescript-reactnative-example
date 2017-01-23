module Movie.Data where

import Prelude
import Control.Monad.Aff (Aff)
import Control.Monad.Eff.Exception (error)
import Control.Monad.Error.Class (throwError)
import Control.Monad.Except (runExcept)
import Data.Either (either)
import Data.Foreign.Class (class IsForeign, read, readJSON, readProp)
import Data.Foreign.NullOrUndefined (NullOrUndefined(..))
import Data.Int (floor)
import Data.Maybe (maybe)
import Data.String (Pattern(..), split)
import Global (readInt)
import Network.HTTP.Affjax (AJAX, affjax, defaultRequest, get)
import Network.HTTP.RequestHeader (RequestHeader(..))
import ReactNative.Components.Navigator (Navigator)
import ReactNative.Components.NavigatorIOS (NavigatorIOS)
import ReactNative.PropTypes (ImageSource, uriSrc)
import ReactNative.PropTypes.Color (rgbi)
import ReactNative.Styles (Styles, staticStyles)
import ReactNative.Styles.Text (color)

data MovieNavigator = MovieNavigator Navigator | MovieNavigatorIOS NavigatorIOS

type MovieR r = {
    id :: String
  , score :: Int
  , title :: String
  , year :: String
  , thumbnail :: String
  | r
}

type Movie = MovieR ()

type MovieDetails = MovieR (
    mpaa_rating :: String
  , synopsis :: String
  , actors :: Array String
)
newtype RTMovie = RTMovie MovieDetails
newtype OMDBMovie = OMDBMovie (MovieR ())
newtype OMDBDetails = OMDBDetails MovieDetails

class MovieClass a where
  unwrapMovie :: a -> Movie
  loadDetails :: forall eff. a -> Aff (ajax::AJAX|eff) MovieDetails

newtype RTActor = RTActor {
  name :: String
}
instance rtActorIF :: IsForeign RTActor where
  read value = do
    name <- readProp "name" value
    pure $ RTActor {name}

instance rtMovieIF :: IsForeign RTMovie where
  read value = do
    id <- readProp "id" value
    title <- readProp "title" value
    ratingsF <- readProp "ratings" value
    score <- readProp "critics_score" ratingsF
    year <- readProp "year" value
    postersF <- readProp "posters" value
    thumbnail <- readProp "thumbnail" postersF
    mpaa_rating <- readProp "mpaa_rating" value
    synopsis <- readProp "synopsis" value
    (NullOrUndefined actorsM) <- readProp "actors" value
    let actors = maybe [] (map (\(RTActor {name}) -> name)) actorsM
    pure $ RTMovie $ {id,title,score,year,thumbnail,mpaa_rating,synopsis,actors}

instance omdbMovieIF :: IsForeign OMDBMovie where
  read value = do
    title <- readProp "Title" value
    year <- readProp "Year" value
    id <- readProp "imdbID" value
    thumbnail <- readProp "Poster" value
    pure $ OMDBMovie $ {id,title,year,thumbnail,score: -1}

instance omdbDetailsIF :: IsForeign OMDBDetails where
  read value = do
    (OMDBMovie {id,title,year,thumbnail}) <- read value
    synopsis <- readProp "Plot" value
    mpaa_rating <- readProp "Rated" value
    score <- parseInt (-1) <$> readProp "tomatoMeter" value
    actors_ <- readProp "Actors" value
    pure $ OMDBDetails $ {id,title,year,thumbnail,score,mpaa_rating, synopsis,actors:split (Pattern ",\\w.") actors_}

newtype OMDBResponse = OMDBResponse {
    totalResults :: Int
  , results :: Array OMDBMovie
}

parseInt :: Int -> String -> Int
parseInt d "N/A" = d
parseInt d s = floor $ readInt 10 s

instance omdbSR :: IsForeign OMDBResponse where
  read value = do
    resp <- readProp "Response" value
    case resp of
      "True" -> do
        results <- readProp "Search" value
        totalResults <- parseInt (-1) <$> readProp "totalResults" value
        pure $ OMDBResponse {totalResults, results}
      _ -> pure $ OMDBResponse {totalResults: -1, results:[]}

data Route = Search | ShowMovie MovieDetails

getImageSource :: forall r. MovieR r -> ImageSource
getImageSource m = uriSrc m.thumbnail

noScore :: Styles
noScore = staticStyles [
  color $ rgbi 0x999999
]

getStyleFromScore :: Int -> Styles
getStyleFromScore _ = noScore

getTextFromScore :: Int -> String
getTextFromScore s = if s > 0 then show s <> "%" else "N/A"

apiUrl :: String
apiUrl = "http://api.rottentomatoes.com/api/public/v1.0/"

apiKey :: String
apiKey = "???"

omdbUrl :: String
omdbUrl = "http://www.omdbapi.com/"

latestRTMovies :: forall eff. Aff (ajax::AJAX|eff) (Array RTMovie)
latestRTMovies = do
  {response} <- get (apiUrl <> "lists/movies/in_theaters.json?apikey=" <> apiKey <>"&page_limit=20&page=1")
  either ((error <<< show) >>> throwError) pure $ runExcept $ (readJSON response)

searchOMDB :: forall eff. String -> Aff (ajax::AJAX|eff) (Array OMDBMovie)
searchOMDB q = do
  {response} <- affjax $ defaultRequest {headers=[RequestHeader "Accept-Encoding" "identity"], url=searchUrl}
  either ((error <<< show) >>> throwError) handleResponse $ runExcept $ (readJSON response)
  where
    handleResponse (OMDBResponse {results}) = pure results
    searchUrl = omdbUrl <> "?type=movie&s=" <> q



instance omdbMovie :: MovieClass OMDBMovie where
  unwrapMovie (OMDBMovie m) = m
  loadDetails (OMDBMovie m) = do
    {response} <- affjax $ defaultRequest {headers=[RequestHeader "Accept-Encoding" "identity"], url=(omdbUrl <> "?i=" <> m.id <> "&plot=full&tomatoes=true")}
    either ((error <<< show) >>> throwError) (pure <<< unwrapDetails) $ runExcept $ (readJSON response)
      where unwrapDetails (OMDBDetails o) = o
