module OpenAI.Servant.V1.ListOf
    ( -- * Types
      ListOf(..)
    ) where

import OpenAI.Servant.Prelude

-- | Whenever OpenAI says that an API endpoint returns a list of items, what
-- they actually mean is that it returns that list wrapped inside of the
-- following object
data ListOf a = List{ data_ :: Vector a , object :: Text }
    deriving stock (Generic, Show)

instance FromJSON a => FromJSON (ListOf a) where
    parseJSON = genericParseJSON aesonOptions
