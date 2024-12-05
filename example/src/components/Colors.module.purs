module Colors.Styles (wrapper) where
foreign import _styles :: String -> String
wrapper :: String
wrapper = _styles "wrapper"
