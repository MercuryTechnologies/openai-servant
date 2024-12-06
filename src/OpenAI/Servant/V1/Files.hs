-- | @\/v1\/files@
module OpenAI.Servant.V1.Files
    ( -- * API
      Request(..)
    , Order(..)
    , File(..)
    , Purpose(..)
    , Status(..)
    , API
    ) where

import OpenAI.Servant.Prelude
import OpenAI.Servant.V1.ListOf

import qualified Data.Text as Text

-- | Sort order by the `created_at` timestamp of the objects
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

-- | The `File` object represents a document that has been uploaded to OpenAI
data File = File
    { id :: Text
    , bytes :: Natural
    , created_at :: POSIXTime
    , filename :: Text
    , object :: Text
    , file_purpose :: Purpose
    } deriving stock (Generic, Show)

instance FromJSON File where
    parseJSON = genericParseJSON aesonOptions
        { fieldLabelModifier = stripPrefix "file_" }

-- | The intended purpose of the uploaded file.
data Purpose
    = Assistants
    | Assistants_Output
    | Batch
    | Batch_Output
    | Fine_Tune
    | Fine_Tune_Results
    | Vision
    deriving stock (Generic, Show)

purposeOptions :: Options
purposeOptions = aesonOptions
    { constructorTagModifier = fix . labelModifier }
  where
    fix "fine_tune" = "fine-tune"
    fix "fine_tune_results" = "fine-tune-results"
    fix string = string

instance FromJSON Purpose where
    parseJSON = genericParseJSON purposeOptions

instance ToJSON Purpose where
    toJSON = genericToJSON purposeOptions

instance ToHttpApiData Purpose where
    toUrlPiece Assistants = "assistants"
    toUrlPiece Assistants_Output = "assistants"
    toUrlPiece Batch = "batch"
    toUrlPiece Batch_Output = "batch_output"
    toUrlPiece Fine_Tune = "fine-tune"
    toUrlPiece Fine_Tune_Results = "fine-tune-results"
    toUrlPiece Vision = "vision"

-- | Deletion status
data Status = Status
    { status_id :: Text
    , status_object :: Text
    , deleted :: Bool
    } deriving stock (Generic, Show)

instance FromJSON Status where
    parseJSON = genericParseJSON aesonOptions
        { fieldLabelModifier = stripPrefix "status_" }

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
        :<|>      Capture "file_id" Text
              :>  Get '[JSON] File
        :<|>      Capture "file_id" Text
              :>  Delete '[JSON] Status
        :<|>      Capture "file_id" Text
              :>  "content"
              :>  Get '[OctetStream] ByteString
        )
