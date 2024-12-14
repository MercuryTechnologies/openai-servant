-- | @\/v1\/threads@
module OpenAI.Servant.V1.Threads
    ( -- Main types
      Thread(..)
    , _Thread
    , ModifyThread(..)
    , _ModifyThread
    , Message(..)
    , Content(..)
    , ThreadObject(..)

      -- * Other types
    , ImageURL(..)
    , ImageFile(..)
    , Attachment(..)

      -- * Servant
    , API
    ) where

import OpenAI.Servant.Prelude
import OpenAI.Servant.V1.DeletionStatus
import OpenAI.Servant.V1.Message
import OpenAI.Servant.V1.ToolResources

-- | Request body for @\/v1\/threads@
data Thread = Thread
    { messages :: Maybe (Vector Message)
    , tool_resources :: Maybe ToolResources
    , metadata :: Maybe (Map Text Text)
    } deriving stock (Generic, Show)
      deriving anyclass (ToJSON)

-- | Default `Thread`
_Thread :: Thread
_Thread = Thread
    { messages = Nothing
    , tool_resources = Nothing
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
data ThreadObject = ThreadObject
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
    :>  (         ReqBody '[JSON] Thread
              :>  Post '[JSON] ThreadObject
        :<|>      Capture "thread_id" Text
              :>  Get '[JSON] ThreadObject
        :<|>      Capture "thread_id" Text
              :>  ReqBody '[JSON] ModifyThread
              :>  Post '[JSON] ThreadObject
        :<|>      Capture "thread_id" Text
              :>  Delete '[JSON] DeletionStatus
        )
