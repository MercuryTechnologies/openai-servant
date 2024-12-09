-- | @\/v1\/files@
module OpenAI.Servant.V1.Files
    ( -- * Main types
      UploadFile(..)
    , _UploadFile
    , File(..)
    -- * Other types
    , Order(..)
    , Purpose(..)
    , DeletionStatus(..)
    -- * Servant
    , API
    ) where

import OpenAI.Servant.Prelude
import OpenAI.Servant.V1.DeletionStatus
import OpenAI.Servant.V1.ListOf
import OpenAI.Servant.V1.Order

import qualified Data.Text as Text

-- | UploadFile body
data UploadFile = UploadFile
    { file :: FilePath
    , purpose :: Purpose
    } deriving stock (Generic, Show)

-- | Default `UploadFile`
_UploadFile :: UploadFile
_UploadFile = UploadFile{ }

instance ToMultipart Tmp UploadFile where
    toMultipart UploadFile{..} = MultipartData{..}
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
    , purpose :: Purpose
    } deriving stock (Generic, Show)
      deriving anyclass (FromJSON)

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

-- | Servant API
type API =
        "files"
    :>  (         MultipartForm Tmp UploadFile
              :>  Post '[JSON] File
        :<|>      QueryParam "purpose" Purpose
              :>  QueryParam "limit" Natural
              :>  QueryParam "order" Order
              :>  QueryParam "after" Text
              :>  Get '[JSON] (ListOf File)
        :<|>      Capture "file_id" Text
              :>  Get '[JSON] File
        :<|>      Capture "file_id" Text
              :>  Delete '[JSON] DeletionStatus
        :<|>      Capture "file_id" Text
              :>  "content"
              :>  Get '[OctetStream] ByteString
        )
