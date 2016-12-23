# Example purescript-reactnative Movie app

This is a `purescript-reactnative` & `purescript-react-simpelaction` based port of the [Movies](https://github.com/facebook/react-native/tree/master/Examples/Movies) example react native app, with a couple of differences at the moment:

- It points to https://www.omdbapi.com/ instead of rotten tomatoes
- It's currently Android only
- Scrolling beyond the first 10 results is not supported yet
- Queries aren't cached

# Running it on Android

Start your emulator or phone

```
npm install
bower update
npm run build
react-native run-android
```

You may also have to start the react-native dev server with (in the repo dir):

```
react-native start
```

also you may need to proxy the dev server with:

```
adb reverse tcp:8081 tcp:8081
```
