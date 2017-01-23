module Movie.SearchBar where

import ReactNative.Events (TextInputEvent, EventHandler)

type SearchBarProps eff = {
    onSearchChange :: EventHandler eff TextInputEvent
  , onFocus :: EventHandler eff TextInputEvent
  , isLoading :: Boolean
}

data Action = Focus
