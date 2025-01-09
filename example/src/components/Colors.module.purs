module Colors.Styles (wrapper,foo,bar,wrapperTwo) where
foreign import _styles :: String -> String
wrapper :: String
wrapper = _styles "wrapper"
foo :: String
foo = _styles "foo"
bar :: String
bar = _styles "bar"
wrapperTwo :: String
wrapperTwo = _styles "wrapperTwo"