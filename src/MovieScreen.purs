module Movies.MovieScreen where

import Prelude
import Movie.Data (MovieDetails, getImageSource, getStyleFromScore, getTextFromScore)
import React (ReactElement)
import ReactNative.Components.Image (image)
import ReactNative.Components.ScrollView (scrollView')
import ReactNative.Components.Text (text, text', text_)
import ReactNative.Components.View (view, view_)
import ReactNative.PropTypes.Color (black, rgba, rgbi)
import ReactNative.Styles (Styles, backgroundColor, borderColor, borderWidth, flex, hairlineWidth, height, marginBottom, marginLeft, marginRight, marginTop, marginVertical, padding, paddingHorizontal, staticStyles, styles', width)
import ReactNative.Styles.Flex (alignSelf, flexDirection, flexStart, justifyContent, row, spaceBetween)
import ReactNative.Styles.Text (fontFamily, fontSize, fontWeight, weight500)



movieScreen :: MovieDetails -> ReactElement
movieScreen m = scrollView' _ {contentContainerStyle=sheet.contentContainer} [
    view sheet.mainSection [
      image sheet.detailsImage $ getImageSource m
    , view sheet.rightPane [
        text sheet.movieTitle m.title
      , text_ m.year
      , view sheet.mpaaWrapper [
          text sheet.mpaaText m.mpaa_rating
        ]
      , ratings
      ]
    ]
  , sep
  , text_ m.synopsis
  , sep
  , cast
  ]
  where
    sep = view sheet.separator []
    ratings = view_ [
      rating m.score "Critics"
    ]
    rating s t = view sheet.rating [
      text sheet.ratingTitle $ t <> ":"
    , text (styles' [sheet.ratingValue, getStyleFromScore s]) $ getTextFromScore s
    ]
    cast = view_ $ [
      text sheet.castTitle "Actors"
    ] <> ((\name -> text' _ {key=name, style=sheet.castActor} name) <$> m.actors)


sheet :: { contentContainer :: Styles
, rightPane :: Styles
, movieTitle :: Styles
, rating :: Styles
, ratingTitle :: Styles
, ratingValue :: Styles
, mpaaWrapper :: Styles
, mpaaText :: Styles
, mainSection :: Styles
, detailsImage :: Styles
, separator :: Styles
, castTitle :: Styles
, castActor :: Styles
}
sheet = {
  contentContainer: staticStyles [
    padding 10
  ],
  rightPane: staticStyles [
    justifyContent spaceBetween,
    flex 1
  ],
  movieTitle: staticStyles [
    flex 1,
    fontSize 16,
    fontWeight weight500
  ],
  rating: staticStyles [
    marginTop 10
  ],
  ratingTitle: staticStyles [
    fontSize 14
  ],
  ratingValue: staticStyles [
    fontSize 28,
    fontWeight weight500
  ],
  mpaaWrapper: staticStyles [
    alignSelf flexStart,
    borderColor black,
    borderWidth 1,
    paddingHorizontal 3,
    marginVertical 5
  ],
  mpaaText: staticStyles [
    fontFamily "Palatino",
    fontSize 13,
    fontWeight weight500
  ],
  mainSection: staticStyles [
    flexDirection row
  ],
  detailsImage: staticStyles [
    width 134,
    height 200,
    backgroundColor $ rgbi 0xeaeaea,
    marginRight 10
  ],
  separator: staticStyles [
    backgroundColor $ rgba 0 0 0 0.1,
    height hairlineWidth,
    marginVertical 10
  ],
  castTitle: staticStyles [
    fontWeight weight500,
    marginBottom 3
  ],
  castActor: staticStyles [
    marginLeft 2
  ]
}
