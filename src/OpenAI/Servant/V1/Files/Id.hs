-- | @\/v1\/files\/:id@
module OpenAI.Servant.V1.Files.Id
    ( -- * API
      API
    ) where

import OpenAI.Servant.Prelude
import OpenAI.Servant.V1.Files.File

-- | API
type API = Capture "file_id" Text :> Get '[JSON] File
