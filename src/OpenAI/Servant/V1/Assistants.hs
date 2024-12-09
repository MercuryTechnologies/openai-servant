-- | @\/v1\/assistants@
module OpenAI.Servant.V1.Assistants
    ( -- * Main types
      CreateAssistant(..)
    , _CreateAssistant
    , ModifyAssistant(..)
    , _ModifyAssistant
    , Assistant(..)

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

-- | The ranking options for the file search
data RankingOptions = RankingOptions
    { ranker :: Maybe Text
    , score_threshold :: Double
    } deriving stock (Generic, Show)
      deriving anyclass (FromJSON, ToJSON)

-- | Overrides for the file search tool
data FileSearch = FileSearch
    { max_num_results :: Maybe Natural
    , ranking_options :: Maybe RankingOptions
    } deriving stock (Generic, Show)
      deriving anyclass (FromJSON, ToJSON)

-- | The Function tool
data Function = Function
    { description :: Maybe Text
    , name :: Text
    , parameters :: Maybe Value
    , strict :: Maybe Bool
    } deriving stock (Generic, Show)
      deriving anyclass (FromJSON, ToJSON)

-- | A tool enabled on the assistant
data Tool
    = Tool_Code_Interpreter
    | Tool_File_Search{ file_search :: FileSearch }
    | Tool_Function{ function :: Function }
    deriving stock (Generic, Show)

toolOptions :: Options
toolOptions = aesonOptions
    { sumEncoding =
        TaggedObject{ tagFieldName = "type", contentsFieldName = "" }

    , tagSingleConstructors = True

    , constructorTagModifier = stripPrefix "Tool_"
    }

instance FromJSON Tool where
    parseJSON = genericParseJSON toolOptions

instance ToJSON Tool where
    toJSON = genericToJSON toolOptions

-- | Resources for the code search tool
data CodeInterpreterResources = CodeInterpreterResources
    { file_ids :: Maybe (Vector Text)
    } deriving stock (Generic, Show)
      deriving anyclass (FromJSON, ToJSON)

-- | Resources for the file search tool
data FileSearchResources = FileSearchResources
    { vector_store_ids :: Maybe (Vector Text)
    } deriving stock (Generic, Show)
      deriving anyclass (FromJSON, ToJSON)

-- | A set of resources that are used by the assistant's tools
data ToolResources = ToolResources
    { code_interpreter :: Maybe CodeInterpreterResources
    , file_search :: Maybe FileSearchResources
    } deriving stock (Generic, Show)
      deriving anyclass (FromJSON, ToJSON)

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

-- | Request body for @\/v1\/assistants/:id@
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
data Assistant = Assistant
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
        "assistants"
    :>  Header' '[Required, Strict] "OpenAI-Beta" Text
    :>  (     ReqBody '[JSON] CreateAssistant :> Post '[JSON] Assistant
        :<|>      QueryParam "limit" Natural
              :>  QueryParam "order" Order
              :>  QueryParam "after" Text
              :>  QueryParam "before" Text
              :>  Get '[JSON] (ListOf Assistant)
        :<|>      Capture "assistant_id" Text
              :>  Get '[JSON] Assistant
        :<|>      Capture "assistant_id" Text
              :>  ReqBody '[JSON] ModifyAssistant
              :>  Post '[JSON] Assistant
        :<|>      Capture "assistant_id" Text
              :>  Delete '[JSON] DeletionStatus
        )
