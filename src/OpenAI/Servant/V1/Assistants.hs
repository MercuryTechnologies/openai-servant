-- | @\/v1\/assistants@
module OpenAI.Servant.V1.Assistants
    ( -- * Main types
      CreateAssistant(..)
    , _CreateAssistant
    , ModifyAssistant(..)
    , _ModifyAssistant
    , AssistantObject(..)

      -- * Other types
    , RankingOptions
    , FileSearch(..)
    , Function(..)
    , Tool(..)
    , CodeInterpreterResources(..)
    , FileSearchResources(..)
    , ToolResources(..)

      -- * Servant
    , API
    ) where

import OpenAI.Servant.Prelude
import OpenAI.Servant.V1.AutoOr
import OpenAI.Servant.V1.DeletionStatus
import OpenAI.Servant.V1.ListOf
import OpenAI.Servant.V1.Order
import OpenAI.Servant.V1.ResponseFormat
import OpenAI.Servant.V1.Tool
import OpenAI.Servant.V1.ToolResources

-- | Request body for @\/v1\/assistants@
data CreateAssistant = CreateAssistant
    { model :: Text
    , name :: Maybe Text
    , description :: Maybe Text
    , instructions :: Maybe Text
    , tools :: Maybe (Vector Tool)
    , tool_resources :: Maybe ToolResources
    , metadata :: Maybe (Map Text Text)
    , temperature :: Maybe Double
    , top_p :: Maybe Double
    , response_format :: Maybe (AutoOr ResponseFormat)
    } deriving stock (Generic, Show)

instance ToJSON CreateAssistant where
    toJSON = genericToJSON aesonOptions

-- | Default `CreateAssistant`
_CreateAssistant :: CreateAssistant
_CreateAssistant = CreateAssistant
    { name = Nothing
    , description = Nothing
    , instructions = Nothing
    , tools = Nothing
    , tool_resources = Nothing
    , metadata = Nothing
    , temperature = Nothing
    , top_p = Nothing
    , response_format = Nothing
    }

-- | Request body for @\/v1\/assistants/:assistant_id@
data ModifyAssistant = ModifyAssistant
    { model :: Text
    , name :: Maybe Text
    , description :: Maybe Text
    , instructions :: Maybe Text
    , tools :: Maybe (Vector Tool)
    , tool_resources :: Maybe ToolResources
    , metadata :: Maybe (Map Text Text)
    , temperature :: Maybe Double
    , top_p :: Maybe Double
    , response_format :: Maybe (AutoOr ResponseFormat)
    } deriving stock (Generic, Show)

instance ToJSON ModifyAssistant where
    toJSON = genericToJSON aesonOptions

-- | Default `ModifyAssistant`
_ModifyAssistant :: ModifyAssistant
_ModifyAssistant = ModifyAssistant
    { name = Nothing
    , description = Nothing
    , instructions = Nothing
    , tools = Nothing
    , tool_resources = Nothing
    , metadata = Nothing
    , temperature = Nothing
    , top_p = Nothing
    , response_format = Nothing
    }

-- | Represents an assistant that can call the model and use tools.
data AssistantObject = AssistantObject
    { id :: Text
    , object :: Text
    , created_at :: POSIXTime
    , name :: Maybe Text
    , description :: Maybe Text
    , model :: Text
    , instructions :: Maybe Text
    , tools :: Maybe (Vector Tool)
    , tool_resources :: Maybe ToolResources
    , metadata :: Map Text Text
    , temperature :: Maybe Double
    , top_p :: Maybe Double
    , response_format :: AutoOr ResponseFormat
    } deriving stock (Generic, Show)
      deriving anyclass (FromJSON)

-- | Servant API
type API =
        Header' '[Required, Strict] "OpenAI-Beta" Text
    :>  "assistants"
    :>  (         ReqBody '[JSON] CreateAssistant
              :>  Post '[JSON] AssistantObject
        :<|>      QueryParam "limit" Natural
              :>  QueryParam "order" Order
              :>  QueryParam "after" Text
              :>  QueryParam "before" Text
              :>  Get '[JSON] (ListOf AssistantObject)
        :<|>      Capture "assistant_id" Text
              :>  Get '[JSON] AssistantObject
        :<|>      Capture "assistant_id" Text
              :>  ReqBody '[JSON] ModifyAssistant
              :>  Post '[JSON] AssistantObject
        :<|>      Capture "assistant_id" Text
              :>  Delete '[JSON] DeletionStatus
        )
