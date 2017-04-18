module Movie.Data where

import Prelude
import Control.Monad.Aff (Aff)
import Control.Monad.Eff.Exception (error)
import Control.Monad.Error.Class (throwError)
import Data.Argonaut.Decode (class DecodeJson, decodeJson, (.?))
import Data.Argonaut.Decode.Combinators ((.??))
import Data.Argonaut.Parser (jsonParser)
import Data.Either (Either(..), either)
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

data MovieNavigator = MovieNavigator (Navigator Route) | MovieNavigatorIOS NavigatorIOS

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
  loadDetails :: forall eff. a -> Aff (ajax::AJAX|eff) (Either String MovieDetails)

newtype RTActor = RTActor {
  name :: String
}
instance rtActorIF :: DecodeJson RTActor where
  decodeJson value = do
    o <- decodeJson value
    name <- o .? "name"
    pure $ RTActor {name}

instance rtMovieIF :: DecodeJson RTMovie where
  decodeJson value = do
    o <- decodeJson value
    id <- o .? "id"
    title <- o .? "title"
    score <- o .? "critics_score"
    year <- o .? "year"
    thumbnail <- o .? "thumbnail"
    mpaa_rating <- o .? "mpaa_rating"
    synopsis <- o .? "synopsis"
    actorsM <- o .?? "actors"
    let actors = maybe [] (map (\(RTActor {name}) -> name)) actorsM
    pure $ RTMovie $ {id,title,score,year,thumbnail,mpaa_rating,synopsis,actors}

instance omdbMovieIF :: DecodeJson OMDBMovie where
  decodeJson value = do
    o <- decodeJson value
    title <- o .? "Title"
    year <- o .? "Year"
    id <- o .? "imdbID"
    thumbnail <- o .? "Poster"
    pure $ OMDBMovie $ {id,title,year,thumbnail,score: -1}

instance omdbDetailsIF :: DecodeJson OMDBDetails where
  decodeJson value = do
    (OMDBMovie {id,title,year,thumbnail}) <- decodeJson value
    o <- decodeJson value
    synopsis <- o .? "Plot"
    mpaa_rating <- o .? "Rated"
    score <- parseInt (-1) <$> o .? "tomatoMeter"
    actors_ <- o .? "Actors"
    pure $ OMDBDetails $ {id,title,year,thumbnail,score,mpaa_rating, synopsis,actors:split (Pattern ",\\w.") actors_}

newtype OMDBResponse = OMDBResponse {
    totalResults :: Int
  , results :: Array OMDBMovie
}

parseInt :: Int -> String -> Int
parseInt d "N/A" = d
parseInt d s = floor $ readInt 10 s

instance omdbSR :: DecodeJson OMDBResponse where
  decodeJson value = do
    o <- decodeJson value
    resp <- o .? "Response"
    case resp of
      "True" -> do
        results <- o .? "Search"
        totalResults <- parseInt (-1) <$> o .? "totalResults"
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
  either ((error <<< show) >>> throwError) pure $ (jsonParser response >>= decodeJson)

searchOMDB :: forall eff. String -> Aff (ajax::AJAX|eff) (Either String (Array OMDBMovie))
searchOMDB q = do
  {response} <- affjax $ defaultRequest { headers=[RequestHeader "Accept-Encoding" "identity"]
                                        , url=searchUrl }
  pure $ either (Left <<< show) handleResponse $ jsonParser response >>= decodeJson
  where
    handleResponse (OMDBResponse {results}) = pure results
    searchUrl = omdbUrl <> "?type=movie&s=" <> q



instance omdbMovie :: MovieClass OMDBMovie where
  unwrapMovie (OMDBMovie m) = m
  loadDetails (OMDBMovie m) = do
    {response} <- affjax $ defaultRequest { headers=[RequestHeader "Accept-Encoding" "identity"]
                                          , url= url m }
    pure $ either (Left <<< show) (pure <<< unwrapDetails) $ jsonParser response >>= decodeJson
      where
        url movie = omdbUrl <> "?i=" <> movie.id <> "&plot=full&tomatoes=true"
        unwrapDetails (OMDBDetails o) = o
