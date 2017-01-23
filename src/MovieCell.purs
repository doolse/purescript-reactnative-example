module Movies.MovieCell where

import Prelude
import Movie.Data (Movie, getImageSource, getStyleFromScore, getTextFromScore)
import React (ReactElement)
import ReactNative.Components.Image (image)
import ReactNative.Components.Text (text, text', textElem, texts')
import ReactNative.Components.Touchable (touchableHilight)
import ReactNative.Components.TouchableNativeFeedback (touchableNativeFeedback)
import ReactNative.Components.View (view)
import ReactNative.Events (EventHandler, TouchEvent)
import ReactNative.PropTypes (center)
import ReactNative.PropTypes.Color (rgba, rgbi, white)
import ReactNative.Styles (Styles, backgroundColor, flex, hairlineWidth, height, marginBottom, marginLeft, marginRight, padding, staticStyles, width)
import ReactNative.Styles.Flex (alignItems, flexDirection, row)
import ReactNative.Styles.Text (color, fontSize, fontWeight, weight500)
import ReactNative.Platform (platformOS, Platform(..))

type Props eff = {
    key :: String
  , movie :: Movie
  , onSelect :: EventHandler eff TouchEvent
}

movieCell :: forall eff. Movie -> {onSelect::EventHandler eff TouchEvent} -> ReactElement
movieCell m p =
    let score = m.score
        touchableView :: forall eff'. Platform -> EventHandler eff' TouchEvent -> ReactElement -> ReactElement
        touchableView IOS = touchableHilight
        touchableView Android = touchableNativeFeedback
    in (touchableView platformOS) p.onSelect $ view sheet.row [
        image sheet.cellImage (getImageSource m)
      , view sheet.textContainer [
          text' _ {style=sheet.movieTitle, numberOfLines=2} m.title
        , texts' _ {style=sheet.movieYear, numberOfLines=1} [
            textElem $ m.year <> " "
          , text (getStyleFromScore score) $ "Critics " <> getTextFromScore score
          ]
        ]
    ]

sheet :: { textContainer :: Styles
, movieTitle :: Styles
, movieYear :: Styles
, row :: Styles
, cellImage :: Styles
, cellBorder :: Styles
}
sheet = {
  textContainer: staticStyles [
    flex 1
  ],
  movieTitle: staticStyles [
    flex 1,
    fontSize 16,
    fontWeight weight500,
    marginBottom 2
  ],
  movieYear: staticStyles [
    color $ rgbi 0x999999,
    fontSize 12
  ],
  row: staticStyles [
    alignItems center,
    backgroundColor white,
    flexDirection row,
    padding 5
  ],
  cellImage: staticStyles [
    backgroundColor $ rgbi 0xdddddd,
    height 93,
    marginRight 10,
    width 60
  ],
  cellBorder: staticStyles [
    backgroundColor $ rgba 0 0 0 0.1,
    height hairlineWidth,
    marginLeft 4
  ]
}
