-- | @\/v1\/vector_stores\/:vector_store_id\/files@
module OpenAI.Servant.V1.VectorStores.Files
    ( -- * Main types
      CreateVectorStoreFile(..)
    , _CreateVectorStoreFile
    , VectorStoreFileObject(..)

      -- * Servant
    , API
    ) where

import OpenAI.Servant.Prelude
import OpenAI.Servant.V1.ChunkingStrategy
import OpenAI.Servant.V1.DeletionStatus
import OpenAI.Servant.V1.Error
import OpenAI.Servant.V1.ListOf
import OpenAI.Servant.V1.Order
import OpenAI.Servant.V1.VectorStores.Status

-- | Request body for @\/v1\/vector_stores\/:vector_store_id\/files@
data CreateVectorStoreFile = CreateVectorStoreFile
    { file_id :: Text
    , chunking_strategy :: Maybe Text
    } deriving stock (Generic, Show)
      deriving anyclass (ToJSON)

-- | Default `CreateVectorStoreFile`
_CreateVectorStoreFile :: CreateVectorStoreFile
_CreateVectorStoreFile = CreateVectorStoreFile
    { chunking_strategy = Nothing
    }

-- | A list of files attached to a vector store
data VectorStoreFileObject = VectorStoreFileObject
    { id :: Text
    , object :: Text
    , usage_bytes :: Natural
    , created_at :: POSIXTime
    , vector_store_id :: Text
    , status :: Status
    , last_error :: Maybe Error
    , chunking_strategy :: ChunkingStrategy
    } deriving stock (Generic, Show)
      deriving anyclass (FromJSON)

-- | Servant API
type API =
        "vector_stores"
    :>  Header' '[Required, Strict] "OpenAI-Beta" Text
    :>  (         Capture "vector_store_id" Text
              :>  "files"
              :>  ReqBody '[JSON] CreateVectorStoreFile
              :>  Post '[JSON] VectorStoreFileObject
        :<|>      Capture "vector_store_id" Text
              :>  "files"
              :>  QueryParam "limit" Natural
              :>  QueryParam "order" Order
              :>  QueryParam "after" Text
              :>  QueryParam "before" Text
              :>  QueryParam "filter" Status
              :>  Get '[JSON] (ListOf VectorStoreFileObject)
        :<|>      Capture "vector_store_id" Text
              :>  "files"
              :>  Capture "file_id" Text
              :>  Get '[JSON] VectorStoreFileObject
        :<|>      Capture "vector_store_id" Text
              :>  "files"
              :>  Capture "file_id" Text
              :>  Delete '[JSON] DeletionStatus
        )
