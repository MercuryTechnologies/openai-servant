-- | @\/v1\/vector_stores\/:vector_store_id\/file_batches@
module OpenAI.Servant.V1.VectorStores.FileBatches
    ( -- * Main types
      CreateVectorStoreFileBatch(..)
    , _CreateVectorStoreFileBatch
    , VectorStoreFilesBatchObject(..)

      -- * Servant
    , API
    ) where

import OpenAI.Servant.Prelude
import OpenAI.Servant.V1.ChunkingStrategy
import OpenAI.Servant.V1.ListOf
import OpenAI.Servant.V1.Order
import OpenAI.Servant.V1.VectorStores.FileCounts
import OpenAI.Servant.V1.VectorStores.Status

-- | Request body for @\/v1\/vector_stores\/:vector_store_id\/file_batches@
data CreateVectorStoreFileBatch = CreateVectorStoreFileBatch
    { file_ids :: Vector Text
    , chunking_strategy :: Maybe ChunkingStrategy
    } deriving stock (Generic, Show)
      deriving anyclass (ToJSON)

-- | Default `CreateVectorStoreFileBatch`
_CreateVectorStoreFileBatch :: CreateVectorStoreFileBatch
_CreateVectorStoreFileBatch = CreateVectorStoreFileBatch
    { chunking_strategy = Nothing
    }

-- | A batch of files attached to a vector store
data VectorStoreFilesBatchObject = VectorStoreFilesBatchObject
    { id :: Text
    , object :: Text
    , created_at :: POSIXTime
    , vector_store_id :: Text
    , status :: Status
    , file_counts :: Maybe FileCounts
    } deriving stock (Generic, Show)
      deriving anyclass (FromJSON)

-- | Servant API
type API =
        "vector_stores"
    :>  Header' '[Required, Strict] "OpenAI-Beta" Text
    :>  (         Capture "vector_store_id" Text
              :>  "file_batches"
              :>  ReqBody '[JSON] CreateVectorStoreFileBatch
              :>  Post '[JSON] VectorStoreFilesBatchObject
        :<|>      Capture "vector_store_id" Text
              :>  "file_batches"
              :>  Capture "batch_id" Text
              :>  Get '[JSON] VectorStoreFilesBatchObject
        :<|>      Capture "vector_store_id" Text
              :>  "file_batches"
              :>  Capture "batch_id" Text
              :>  "cancel"
              :>  Post '[JSON] VectorStoreFilesBatchObject
        :<|>      Capture "vector_store_id" Text
              :>  "file_batches"
              :>  Capture "batch_id" Text
              :>  "files"
              :>  QueryParam "limit" Natural
              :>  QueryParam "order" Order
              :>  QueryParam "after" Text
              :>  QueryParam "before" Text
              :>  QueryParam "filter" Status
              :>  Get '[JSON] (ListOf VectorStoreFilesBatchObject)
        )
