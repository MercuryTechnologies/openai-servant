-- | The response format
module OpenAI.Servant.V1.Images.ResponseFormat
    ( -- * Types
      ResponseFormat(..)
    ) where

import OpenAI.Servant.Prelude

-- | The format in which the generated images are returned
data ResponseFormat = URL | B64_JSON
    deriving stock (Generic, Show)

instance ToJSON ResponseFormat where
    toJSON = genericToJSON aesonOptions

instance ToHttpApiData ResponseFormat where
    toUrlPiece URL = "url"
    toUrlPiece B64_JSON = "b64_json"
