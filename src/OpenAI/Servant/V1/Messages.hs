-- | @\/v1\/threads/:thread_id/messages@
module OpenAI.Servant.V1.Messages
    ( -- * Main types
        Message(..)
      , ModifyMessage(..)
      , _ModifyMessage
      , MessageObject(..)

      -- * Other types
      , Status(..)
      , IncompleteDetails(..)
      , File(..)
      , Annotation(..)
      , TextObject(..)

      -- * Servant
      , API
    ) where

import OpenAI.Servant.Prelude
import OpenAI.Servant.V1.DeletionStatus
import OpenAI.Servant.V1.ListOf
import OpenAI.Servant.V1.Message

-- | Request body for @\/v1\/threads\/:thread_id\/messages\/:message_id@
data ModifyMessage = ModifyMessage
    { metadata :: Maybe (Map Text Text)
    } deriving stock (Generic, Show)

instance ToJSON ModifyMessage where
    toJSON = genericToJSON aesonOptions

-- | Default `ModifyMessage`
_ModifyMessage :: ModifyMessage
_ModifyMessage = ModifyMessage
    { metadata = Nothing
    }

-- | The status of the message
data Status = In_Progress | Incomplete | Completed
    deriving stock (Generic, Show)

instance FromJSON Status where
    parseJSON = genericParseJSON aesonOptions

-- | On an incomplete message, details about why the message is incomplete.
data IncompleteDetails = IncompleteDetails
    { reason :: Text
    } deriving (Generic, Show)
      deriving anyclass (FromJSON)

-- | File
data File = File
    { file_id :: Text
    } deriving stock (Generic, Show)
      deriving anyclass (FromJSON)

-- | An annotation
data Annotation
    = File_Citation
        { text :: Text
        , file_citation :: File
        , start_index :: Natural
        , end_index :: Natural
        }
    | File_Path
        { text :: Text
        , file_path :: File
        , start_index :: Natural
        , end_index :: Natural
        }
    deriving stock (Generic, Show)

instance FromJSON Annotation where
    parseJSON = genericParseJSON aesonOptions
        { sumEncoding =
            TaggedObject{ tagFieldName = "type", contentsFieldName = "" }

        , tagSingleConstructors = True
        }

-- | The text content that is part of a message.
data TextObject = TextObject
    { value :: Text
    , annotations :: Vector Annotation
    } deriving stock (Generic, Show)
      deriving anyclass (FromJSON)

instance IsString TextObject where
    fromString string =
        TextObject{ value = fromString string, annotations = [] }

-- | Represents a message within a thread.
data MessageObject = MessageObject
    { id :: Text
    , object :: Text
    , created_at :: POSIXTime
    , thread_id :: Text
    , status :: Maybe Status
    , incomplete_details :: Maybe IncompleteDetails
    , completed_at :: Maybe POSIXTime
    , incomplete_at :: Maybe POSIXTime
    , role :: Text
    , content :: Vector (Content TextObject)
    , assistant_id :: Maybe Text
    , run_id :: Maybe Text
    , attachments :: Maybe (Vector Attachment)
    , metadata :: Map Text Text
    } deriving (Generic, Show)
      deriving anyclass (FromJSON)

-- | Servant API
type API =
        "threads"
    :>  Header' '[Required, Strict] "OpenAI-Beta" Text
    :>  (         Capture "thread_id" Text
              :>  "messages"
              :>  ReqBody '[JSON] Message
              :>  Post '[JSON] MessageObject
        :<|>      Capture "thread_id" Text
              :>  "messages"
              :>  Get '[JSON] (ListOf MessageObject)
        :<|>      Capture "thread_id" Text
              :>  "messages"
              :>  Capture "message_id" Text
              :>  Get '[JSON] MessageObject
        :<|>      Capture "thread_id" Text
              :>  "messages"
              :>  Capture "message_id" Text
              :>  ReqBody '[JSON] ModifyMessage
              :>  Post '[JSON] MessageObject
        :<|>      Capture "thread_id" Text
              :>  "messages"
              :>  Capture "message_id" Text
              :>  Delete '[JSON] DeletionStatus
        )
