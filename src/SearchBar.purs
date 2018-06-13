module Movie.SearchBar where

import ReactNative.Events (TextInputEvent, EventHandler)

type SearchBarProps = {
    onSearchChange :: EventHandler TextInputEvent
  , onFocus :: EventHandler TextInputEvent
  , isLoading :: Boolean
}

data Action = Focus
