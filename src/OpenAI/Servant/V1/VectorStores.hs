-- | @\/v1\/vector_stores@
module OpenAI.Servant.V1.VectorStores
    ( -- * Main types
      CreateVectorStore(..)
    , _CreateVectorStore
    , ModifyVectorStore(..)
    , _ModifyVectorStore
    , VectorStoreObject(..)

      -- * Other types
    , ExpiresAfter(..)

      -- * Servant
    , API
    ) where

import OpenAI.Servant.Prelude
import OpenAI.Servant.V1.AutoOr
import OpenAI.Servant.V1.ChunkingStrategy
import OpenAI.Servant.V1.DeletionStatus
import OpenAI.Servant.V1.Order
import OpenAI.Servant.V1.ListOf
import OpenAI.Servant.V1.VectorStores.FileCounts

-- | The expiration policy for a vector store.
data ExpiresAfter = ExpiresAfter
    { anchor :: Text
    , days :: Natural
    } deriving stock (Generic, Show)
      deriving anyclass (FromJSON, ToJSON)

-- | Request body for @\/v1\/vector_stores@
data CreateVectorStore = CreateVectorStore
    { file_ids :: Vector Text
    , name :: Maybe Text
    , expires_after :: Maybe ExpiresAfter
    , chunking_strategy :: Maybe (AutoOr ChunkingStrategy)
    , metadata :: Maybe (Map Text Text)
    } deriving stock (Generic, Show)
      deriving (ToJSON)

-- | Default `CreateVectorStore`
_CreateVectorStore :: CreateVectorStore
_CreateVectorStore = CreateVectorStore
    { name = Nothing
    , expires_after = Nothing
    , chunking_strategy = Nothing
    , metadata = Nothing
    }

-- | Request body for @\/v1\/vector_stores\/:vector_store_id@
data ModifyVectorStore = ModifyVectorStore
    { name :: Maybe Text
    , expires_after :: Maybe ExpiresAfter
    , metadata :: Maybe (Map Text Text)
    } deriving stock (Generic, Show)
      deriving (ToJSON)

-- | Default `ModifyVectorStore`
_ModifyVectorStore :: ModifyVectorStore
_ModifyVectorStore = ModifyVectorStore
    { name = Nothing
    , expires_after = Nothing
    , metadata = Nothing
    }

-- | A vector store is a collection of processed files can be used by the
-- @file_search@ tool.
data VectorStoreObject = VectorStoreObject
    { id :: Text
    , object :: Text
    , created_at :: POSIXTime
    , name :: Maybe Text
    , usage_bytes :: Natural
    , file_counts :: FileCounts
    , status :: Text
    , expires_after :: Maybe ExpiresAfter
    , expires_at :: Maybe POSIXTime
    , last_active_at :: Maybe POSIXTime
    , metadata :: Map Text Text
    } deriving stock (Generic, Show)
      deriving anyclass (FromJSON)

-- | Servant API
type API =
        "vector_stores"
    :>  Header' '[Required, Strict] "OpenAI-Beta" Text
    :>  (         ReqBody '[JSON] CreateVectorStore
              :>  Post '[JSON] VectorStoreObject
        :<|>      QueryParam "limit" Natural
              :>  QueryParam "order" Order
              :>  QueryParam "after" Text
              :>  QueryParam "before" Text
              :>  Get '[JSON] (ListOf VectorStoreObject)
        :<|>      Capture "vector_store_id" Text
              :>  Get '[JSON] VectorStoreObject
        :<|>      Capture "vector_store_id" Text
              :>  ReqBody '[JSON] ModifyVectorStore
              :>  Post '[JSON] VectorStoreObject
        :<|>      Capture "vector_store_id" Text
              :>  Delete '[JSON] DeletionStatus
        )
