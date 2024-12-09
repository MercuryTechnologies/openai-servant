-- | The `AutoOr` type constructor
module OpenAI.Servant.V1.AutoOr
    ( -- * Types
      AutoOr(..)
    ) where

import OpenAI.Servant.Prelude

-- | A type that can also be the string @\"auto\"@
data AutoOr a = Auto | Specific a
    deriving stock (Generic, Show)

instance FromJSON a => FromJSON (AutoOr a) where
    parseJSON "auto" = pure Auto
    parseJSON value = fmap Specific (parseJSON value)

instance ToJSON a => ToJSON (AutoOr a) where
    toJSON Auto = "auto"
    toJSON (Specific a) = toJSON a


