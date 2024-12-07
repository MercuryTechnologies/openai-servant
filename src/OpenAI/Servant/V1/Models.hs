-- | @\/v1\/models@
module OpenAI.Servant.V1.Models
    ( -- * Main types
      Model(..)
    , _Model
    , DeletionStatus(..)

      -- * Servant
    , API
    ) where

import OpenAI.Servant.Prelude
import OpenAI.Servant.V1.ListOf

-- | Describes an OpenAI model offering that can be used with the API
data Model = Model
    { id :: Text
    , created :: POSIXTime
    , object :: Text
    , owned_by :: Text
    } deriving stock (Generic, Show)
      deriving anyclass (FromJSON)

-- | Default `Model`
_Model :: Model
_Model = Model{ }

-- | Deletion status
data DeletionStatus = DeletionStatus
    { id :: Text
    , object :: Text
    , deleted :: Bool
    } deriving stock (Generic, Show)
      deriving anyclass (FromJSON)

-- | Servant API
type API =
        "models"
    :>  (         Get '[JSON] (ListOf Model)
        :<|>      Capture "model" Text
              :>  Get '[JSON] Model
        :<|>      Capture "model" Text
              :>  Delete '[JSON] DeletionStatus
        )
