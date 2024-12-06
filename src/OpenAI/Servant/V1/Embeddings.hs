-- | @\/v1\/embeddings@
module OpenAI.Servant.V1.Embeddings
    ( -- * API
      EncodingFormat(..)
    , Request(..)
    , Embedding(..)
    , Response
    , API
    ) where

import OpenAI.Servant.Prelude
import OpenAI.Servant.V1.ListOf

-- | The format to return the embeddings in
data EncodingFormat = Float | Base64
    deriving stock (Generic, Show)

instance ToJSON EncodingFormat where
    toJSON = genericToJSON aesonOptions

-- | Request body
data Request = Request
    { input :: Text
    , model :: Text
    , encoding_format :: Maybe EncodingFormat
    , dimensions :: Maybe Natural
    , user :: Maybe Text
    } deriving stock (Generic, Show)
      deriving anyclass (ToJSON)

-- | The embedding object
data Embedding = Embbedding
    { index :: Natural
    , embedding :: Vector Double
    , embedding_object :: Text
    } deriving stock (Generic, Show)

instance FromJSON Embedding where
    parseJSON = genericParseJSON aesonOptions
        { fieldLabelModifier = stripPrefix "embedding_" }

-- | Response body
type Response = ListOf Embedding

-- | API
type API = "embeddings" :> ReqBody '[JSON] Request :> Post '[JSON] Response
