-- | @\/v1\/files\/:id@
module OpenAI.Servant.V1.Files.Id
    ( -- * API
      API
    ) where

import OpenAI.Servant.Prelude
import OpenAI.Servant.V1.Files.File

data DeletionStatus = DeletionStatus
    { id :: Text
    , object :: Text
    , deleted :: Bool
    } deriving stock (Generic, Show)
      deriving anyclass (FromJSON)

-- | API
type API =
          Capture "file_id" Text :> Get '[JSON] File
    :<|>  Capture "file_id" Text :> Delete '[JSON] DeletionStatus
