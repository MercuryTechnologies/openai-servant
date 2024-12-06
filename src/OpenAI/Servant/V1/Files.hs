-- | @\/v1\/files@
module OpenAI.Servant.V1.Files
    ( -- * API
      Request(..)
    , Order(..)
    , API
    ) where

import OpenAI.Servant.Prelude
import OpenAI.Servant.V1.Files.File
import OpenAI.Servant.V1.Files.Purpose as Purpose
import OpenAI.Servant.V1.ListOf

import qualified Data.Text as Text
import qualified OpenAI.Servant.V1.Files.Id as Id

data Order = Desc | Asc

instance ToHttpApiData Order where
    toUrlPiece Desc = "desc"
    toUrlPiece Asc = "asc"

-- | Request body
data Request = Request
    { file :: FilePath
    , purpose :: Purpose
    } deriving stock (Generic, Show)

instance ToMultipart Tmp Request where
    toMultipart Request{..} = MultipartData{..}
      where
        inputs = input "purpose" (toUrlPiece purpose)

        files = [ FileData{..} ]
          where
            fdInputName = "file"
            fdFileName = Text.pack file
            fdFileCType = "application/json"
            fdPayload = file

-- | API
type API =
        "files"
    :>  (         MultipartForm Tmp Request
              :>  Post '[JSON] File
        :<|>      QueryParam "purpose" Purpose
              :>  QueryParam "limit" Natural
              :>  QueryParam "order" Order
              :>  QueryParam "after" Text
              :>  Get '[JSON] (ListOf File)
        :<|>      Id.API
        )
