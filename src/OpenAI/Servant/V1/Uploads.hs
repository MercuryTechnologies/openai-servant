-- | @\/v1\/uploads@
{-# LANGUAGE InstanceSigs #-}
module OpenAI.Servant.V1.Uploads
    ( -- * API
      CreateUpload(..)
    , AddUploadPart(..)
    , CompleteUpload(..)
    , Status(..)
    , Upload(..)
    , Part(..)
    , API
    ) where

import OpenAI.Servant.Prelude
import OpenAI.Servant.V1.Files (File, Purpose)

import qualified Data.Text as Text

-- | Request body for @\/v1\/uploads@
data CreateUpload = CreateUpload
    { filename :: Text
    , purpose :: Purpose
    , bytes :: Natural
    , mime_type :: Text
    } deriving stock (Generic, Show)
      deriving anyclass (ToJSON)

-- | Request body for @\/v1\/uploads\/:id\/parts@
data AddUploadPart = AddUploadPart{ data_ :: FilePath }

instance ToMultipart Tmp AddUploadPart where
    toMultipart AddUploadPart{..} = MultipartData{..}
      where
        inputs = mempty

        files = [ FileData{..} ]
          where
            fdInputName = "data"
            fdFileName = Text.pack data_
            fdFileCType = "application/octet-stream"
            fdPayload = data_

-- | Request body for @\/v1\/uploads\/:id\/complete@
data CompleteUpload = CompleteUpload
    { part_ids :: Vector Text
    , md5 :: Maybe Text
    } deriving stock (Generic, Show)

-- OpenAI says that the `md5` field is optional, but what they really mean is
-- that it can be set to the empty string.  We still model it as `Maybe Text`,
-- but convert `Nothing` to an empty string at encoding time.
instance ToJSON CompleteUpload where
    toJSON completeUpload = genericToJSON aesonOptions (fix completeUpload)
      where
        fix CompleteUpload{ md5 = Nothing, .. } =
            CompleteUpload{ md5 = Just "", .. }
        fix x = x

-- | The status of the `Upload`
data Status
    = Pending
    | Completed
    | Cancelled
    | Expired
    deriving stock (Generic, Show)

instance FromJSON Status where
    parseJSON = genericParseJSON aesonOptions

-- | The Upload object can accept byte chunks in the form of Parts.
data Upload file = Upload
    { id :: Text
    , created_at :: POSIXTime
    , upload_filename :: Text
    , upload_bytes :: Natural
    , upload_purpose :: Purpose
    , status :: Status
    , expires_at :: POSIXTime
    , upload_object :: Text
    , file :: file
    } deriving stock (Generic, Show)

-- The reason this is not:
--
-- instance FromJSON file => FromJSON (Upload file)
--
-- … is because that doesn't correctly handle the case where `file = Maybe b`.
-- Specifically, it doesn't allow the field to be omitted even if the field
-- can be `Nothing`.  However, adding a concrete instance avoids this issue.
instance FromJSON (Upload (Maybe Void)) where
    parseJSON = genericParseJSON aesonOptions
        { fieldLabelModifier = stripPrefix "upload_" }

instance FromJSON (Upload File) where
    parseJSON = genericParseJSON aesonOptions
        { fieldLabelModifier = stripPrefix "upload_" }

data Part = Part
    { part_id :: Text
    , part_created_at :: POSIXTime
    , upload_id :: Text
    , part_object :: Text
    } deriving stock (Generic, Show)

instance FromJSON Part where
    parseJSON = genericParseJSON aesonOptions
        { fieldLabelModifier = stripPrefix "part_" }

-- | API
type API
    = "uploads"
    :>  (         ReqBody '[JSON] CreateUpload
              :>  Post '[JSON] (Upload (Maybe Void))
        :<|>      Capture "upload_id" Text
              :>  "parts"
              :>  MultipartForm Tmp AddUploadPart
              :>  Post '[JSON] Part
        :<|>      Capture "upload_id" Text
              :>  "complete"
              :>  ReqBody '[JSON] CompleteUpload
              :>  Post '[JSON] (Upload File)
        :<|>      Capture "upload_id" Text
              :>  "cancel"
              :>  Post '[JSON] (Upload (Maybe Void))
        )
