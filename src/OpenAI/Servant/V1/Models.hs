-- | @\/v1\/models@
module OpenAI.Servant.V1.Models
    ( -- * Main types
      ModelObject(..)

      -- * Servant
    , API
    ) where

import OpenAI.Servant.Prelude
import OpenAI.Servant.V1.DeletionStatus
import OpenAI.Servant.V1.ListOf

-- | Describes an OpenAI model offering that can be used with the API
data ModelObject = ModelObject
    { id :: Text
    , created :: POSIXTime
    , object :: Text
    , owned_by :: Text
    } deriving stock (Generic, Show)
      deriving anyclass (FromJSON)

-- | Servant API
type API =
        "models"
    :>  (         Get '[JSON] (ListOf ModelObject)
        :<|>      Capture "model" Text
              :>  Get '[JSON] ModelObject
        :<|>      Capture "model" Text
              :>  Delete '[JSON] DeletionStatus
        )
