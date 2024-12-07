-- | @\/v1\/embeddings@
module OpenAI.Servant.V1.Embeddings
    ( -- * API
      EncodingFormat(..)
    , CreateEmbeddings(..)
    , Embedding(..)
    , API
    ) where

import OpenAI.Servant.Prelude
import OpenAI.Servant.V1.ListOf

-- | The format to return the embeddings in
data EncodingFormat = Float | Base64
    deriving stock (Generic, Show)

instance ToJSON EncodingFormat where
    toJSON = genericToJSON aesonOptions

-- | Request body for @\/v1\/embeddings@
data CreateEmbeddings = CreateEmbeddings
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

-- | API
type API =
        "embeddings"
    :>  ReqBody '[JSON] CreateEmbeddings
    :>  Post '[JSON] (ListOf Embedding)
