module Node.Nanomatch ( isMatch, capture ) where

foreign import isMatch :: String -> String -> Boolean
foreign import capture :: String -> String -> Array String
