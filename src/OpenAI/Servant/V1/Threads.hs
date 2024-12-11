-- | @\/v1\/threads@
module OpenAI.Servant.V1.Threads
    ( -- Main types
      CreateThread(..)
    , _CreateThread
    , ModifyThread(..)
    , _ModifyThread
    , Message(..)
    , Content(..)
    , Thread(..)

      -- * Other types
    , ImageURL(..)
    , ImageFile(..)
    , Attachment(..)

      -- * Servant
    , API
    ) where

import OpenAI.Servant.Prelude
import OpenAI.Servant.V1.AutoOr
import OpenAI.Servant.V1.DeletionStatus
import OpenAI.Servant.V1.Tool
import OpenAI.Servant.V1.ToolResources

-- | References an image File in the content of a message
data ImageFile = ImageFile{ file_id :: Text, detail :: Maybe (AutoOr Text) }
    deriving stock (Generic, Show)
    deriving anyclass (ToJSON)

-- | References an image URL in the content of a message
data ImageURL = ImageURL
    { image_url :: Text
    , detail :: Maybe (AutoOr Text)
    } deriving stock (Generic, Show)
      deriving anyclass (ToJSON)

-- | Message content
data Content
    = Image_File{ image_file :: ImageFile }
    | Image_URL{ image_url :: ImageURL }
    | Text{ text :: Text }
    deriving stock (Generic, Show)

instance ToJSON Content where
    toJSON = genericToJSON aesonOptions
        { sumEncoding =
            TaggedObject{ tagFieldName = "type", contentsFieldName = "" }

        , tagSingleConstructors = True
        }

-- | A file attached to the message, and the tools it should be added to
data Attachment = Attachment{ file_id :: Text, tools :: Maybe (Vector Tool) }
    deriving stock (Generic, Show)
    deriving anyclass (ToJSON)

instance IsString Content where
    fromString string = Text{ text = fromString string }

-- | A message
data Message
    = User
        { content :: Vector Content
        , attachments :: Maybe (Vector Attachment)
        , metadata :: Maybe (Map Text Text)
        }
    | Assistant
        { content :: Vector Content
        , attachments :: Maybe (Vector Attachment)
        , metadata :: Maybe (Map Text Text)
        }
    deriving stock (Generic, Show)

instance ToJSON Message where
    toJSON = genericToJSON aesonOptions
        { sumEncoding =
            TaggedObject{ tagFieldName = "role", contentsFieldName = "" }

        , tagSingleConstructors = True
        }

-- | Request body for @\/v1\/threads@
data CreateThread = CreateThread
    { messages :: Vector Message
    , tool_resources :: Maybe ToolResources
    , metadata :: Maybe (Map Text Text)
    } deriving stock (Generic, Show)
      deriving anyclass (ToJSON)

-- | Default `CreateThread`
_CreateThread :: CreateThread
_CreateThread = CreateThread
    { tool_resources = Nothing
    , metadata = Nothing
    }

-- | Request body for @\/v1\/threads\/:thread_id@
data ModifyThread = ModifyThread
    { tool_resources :: Maybe ToolResources
    , metadata :: Maybe (Map Text Text)
    } deriving stock (Generic, Show)

instance ToJSON ModifyThread where
    toJSON = genericToJSON aesonOptions

-- | Default `ModifyThread`
_ModifyThread :: ModifyThread
_ModifyThread = ModifyThread
    { tool_resources = Nothing
    , metadata = Nothing
    }

-- | Represents a thread that contains messages
data Thread = Thread
    { id :: Text
    , object :: Text
    , created_at :: POSIXTime
    , tool_resources :: Maybe ToolResources
    , metadata :: Maybe (Map Text Text)
    } deriving stock (Generic, Show)
      deriving anyclass (FromJSON)

-- | Servant API
type API =
        "threads"
    :>  Header' '[Required, Strict] "OpenAI-Beta" Text
    :>  (         ReqBody '[JSON] CreateThread
              :>  Post '[JSON] Thread
        :<|>      Capture "thread_id" Text
              :>  Get '[JSON] Thread
        :<|>      Capture "thread_id" Text
              :>  ReqBody '[JSON] ModifyThread
              :>  Post '[JSON] Thread
        :<|>      Capture "thread_id" Text
              :>  Delete '[JSON] DeletionStatus
        )
