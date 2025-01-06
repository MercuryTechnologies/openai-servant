-- | @\/v1\/threads\/:thread_id\/runs@
module OpenAI.Servant.V1.Threads.Runs
    ( -- * Main types
      CreateRun(..)
    , _CreateRun
    , CreateThreadAndRun(..)
    , _CreateThreadAndRun
    , ModifyRun(..)
    , _ModifyRun
    , SubmitToolOutputsToRun(..)
    , _SubmitToolOutputsToRun
    , RunObject(..)

      -- * Other types
    , TruncationStrategy(..)
    , SubmitToolOutputs(..)
    , RequiredAction(..)
    , IncompleteDetails(..)
    , ToolOutput(..)

      -- * Servant
    , API
    ) where

import OpenAI.Servant.Prelude
import OpenAI.Servant.V1.AutoOr
import OpenAI.Servant.V1.Error
import OpenAI.Servant.V1.ListOf
import OpenAI.Servant.V1.Message
import OpenAI.Servant.V1.Order
import OpenAI.Servant.V1.ResponseFormat
import OpenAI.Servant.V1.Threads (Thread)
import OpenAI.Servant.V1.Tool
import OpenAI.Servant.V1.ToolCall
import OpenAI.Servant.V1.ToolResources
import OpenAI.Servant.V1.Usage

import qualified OpenAI.Servant.V1.Threads.Runs.Steps as Steps

-- | Controls for how a thread will be truncated prior to the run
data TruncationStrategy
    = Auto
    | Last_Messages{ last_messages :: Maybe Natural }
    deriving stock (Generic, Show)

truncationStrategyOptions :: Options
truncationStrategyOptions = aesonOptions
    { sumEncoding =
        TaggedObject{ tagFieldName = "type", contentsFieldName = "" }

    , tagSingleConstructors = True
    }

instance FromJSON TruncationStrategy where
    parseJSON = genericParseJSON truncationStrategyOptions

instance ToJSON TruncationStrategy where
    toJSON = genericToJSON truncationStrategyOptions

-- | Request body for @\/v1\/threads\/:thread_id\/runs@
data CreateRun = CreateRun
    { assistant_id :: Text
    , model :: Maybe Text
    , instructions :: Maybe Text
    , additional_instructions :: Maybe Text
    , additional_messages :: Maybe (Vector Message)
    , tools :: Maybe (Vector Tool)
    , metadata :: Maybe (Map Text Text)
    , temperature :: Maybe Double
    , top_p :: Maybe Double
    , max_prompt_tokens :: Maybe Natural
    , max_completion_tokens :: Maybe Natural
    , truncation_strategy :: Maybe TruncationStrategy
    , tool_choice :: Maybe ToolChoice
    , parallel_tool_calls :: Maybe Bool
    , response_format :: Maybe (AutoOr ResponseFormat)
    } deriving stock (Generic, Show)

instance ToJSON CreateRun where
    toJSON = genericToJSON aesonOptions

-- | Default `CreateRun`
_CreateRun :: CreateRun
_CreateRun = CreateRun
    { model = Nothing
    , instructions = Nothing
    , additional_instructions = Nothing
    , additional_messages = Nothing
    , tools = Nothing
    , metadata = Nothing
    , temperature = Nothing
    , top_p = Nothing
    , max_prompt_tokens = Nothing
    , max_completion_tokens = Nothing
    , truncation_strategy = Nothing
    , tool_choice = Nothing
    , parallel_tool_calls = Nothing
    , response_format = Nothing
    }

-- | Request body for @\/v1\/threads\/runs@
data CreateThreadAndRun = CreateThreadAndRun
    { assistant_id :: Text
    , thread :: Maybe Thread
    , model :: Maybe Text
    , instructions :: Maybe Text
    , tools :: Maybe (Vector Tool)
    , toolResources :: Maybe ToolResources
    , metadata :: Maybe (Map Text Text)
    , temperature :: Maybe Double
    , top_p :: Maybe Double
    , max_prompt_tokens :: Maybe Natural
    , max_completion_tokens :: Maybe Natural
    , truncation_strategy :: Maybe TruncationStrategy
    , tool_choice :: Maybe ToolChoice
    , parallel_tool_calls :: Maybe Bool
    , response_format :: Maybe (AutoOr ResponseFormat)
    } deriving stock (Generic, Show)

instance ToJSON CreateThreadAndRun where
    toJSON = genericToJSON aesonOptions

-- | Default `CreateThreadAndRun`
_CreateThreadAndRun :: CreateThreadAndRun
_CreateThreadAndRun = CreateThreadAndRun
    { thread = Nothing
    , model = Nothing
    , instructions = Nothing
    , tools = Nothing
    , toolResources = Nothing
    , metadata = Nothing
    , temperature = Nothing
    , top_p = Nothing
    , max_prompt_tokens = Nothing
    , max_completion_tokens = Nothing
    , truncation_strategy = Nothing
    , tool_choice = Nothing
    , parallel_tool_calls = Nothing
    , response_format = Nothing
    }

-- | Details on the tool outputs needed for this run to continue.
data SubmitToolOutputs = SubmitToolOutputs
    { tool_calls :: Vector ToolCall
    } deriving stock (Generic, Show)
      deriving anyclass (FromJSON)

-- | Details on the action required to continue the run
data RequiredAction = RequiredAction_Submit_Tool_Outputs
    { submit_tool_outputs :: SubmitToolOutputs
    } deriving stock (Generic, Show)

instance FromJSON RequiredAction where
    parseJSON = genericParseJSON aesonOptions
        { sumEncoding =
              TaggedObject{ tagFieldName = "type" }

        , tagSingleConstructors = True

        , constructorTagModifier = stripPrefix "RequiredAction_"
        }

-- | Details on why the run is incomplete
data IncompleteDetails = IncompleteDetails
    { reason :: Text
    } deriving stock (Generic, Show)
      deriving anyclass (FromJSON)

-- | Represents an execution run on a thread.
data RunObject = RunObject
    { id :: Text
    , object :: Text
    , created_at :: POSIXTime
    , thread_id :: Text
    , assistant_id :: Text
    , status :: Text
    , required_action :: Maybe RequiredAction
    , last_error :: Maybe Error
    , expires_at :: Maybe POSIXTime
    , started_at :: Maybe POSIXTime
    , cancelled_at :: Maybe POSIXTime
    , failed_at :: Maybe POSIXTime
    , completed_at :: Maybe POSIXTime
    , incomplete_details :: Maybe IncompleteDetails
    , model :: Text
    , instructions :: Maybe Text
    , tools :: Vector Tool
    , metadata :: Map Text Text
    , usage :: Maybe (Usage (Maybe Void) (Maybe Void))
    , temperature :: Maybe Double
    , top_p :: Maybe Double
    , max_prompt_tokens :: Maybe Natural
    , max_completion_tokens :: Maybe Natural
    , truncation_strategy :: Maybe TruncationStrategy
    , tool_choice :: ToolChoice
    , parallel_tool_calls :: Bool
    , response_format :: AutoOr ResponseFormat
    } deriving stock (Generic, Show)
      deriving anyclass (FromJSON)

-- | Request body for @\/v1\/threads\/:thread_id\/runs\/:run_id@
data ModifyRun = ModifyRun
    { metadata :: Maybe (Map Text Text)
    } deriving stock (Generic, Show)

instance ToJSON ModifyRun where
    toJSON = genericToJSON aesonOptions

-- | Default `ModifyRun`
_ModifyRun :: ModifyRun
_ModifyRun = ModifyRun{ }

-- | A tool for which the output is being submitted
data ToolOutput = ToolOutput
    { tool_call_id :: Maybe Text
    , output :: Text
    } deriving stock (Generic, Show)
      deriving anyclass (ToJSON)

-- | Request body for @\/v1\/threads\/:thread_id\/runs\/:run_id\/submit_tool_outputs@
data SubmitToolOutputsToRun = SubmitToolOutputsToRun
    { tool_outputs :: Vector ToolOutput
    } deriving stock (Generic, Show)

instance ToJSON SubmitToolOutputsToRun where
    toJSON = genericToJSON aesonOptions

-- | Default implementation of `SubmitToolOutputsToRun`
_SubmitToolOutputsToRun :: SubmitToolOutputsToRun
_SubmitToolOutputsToRun = SubmitToolOutputsToRun{ }

-- | Servant API
type API =
        "threads"
    :>  Header' '[Required, Strict] "OpenAI-Beta" Text
    :>  (         Capture "thread_id" Text
              :>  "runs"
              :>  QueryParam "include[]" Text
              :>  ReqBody '[JSON] CreateRun
              :>  Post '[JSON] RunObject
        :<|>      "runs"
              :>  ReqBody '[JSON] CreateThreadAndRun
              :>  Post '[JSON] RunObject
        :<|>      Capture "thread_id" Text
              :>  "runs"
              :>  QueryParam "limit" Natural
              :>  QueryParam "order" Order
              :>  QueryParam "after" Text
              :>  QueryParam "before" Text
              :>  Get '[JSON] (ListOf RunObject)
        :<|>      Capture "thread_id" Text
              :>  "runs"
              :>  Capture "run_id" Text
              :>  Get '[JSON] RunObject
        :<|>      Capture "thread_id" Text
              :>  "runs"
              :>  Capture "run_id" Text
              :>  ReqBody '[JSON] ModifyRun
              :>  Post '[JSON] RunObject
        :<|>      Capture "thread_id" Text
              :>  "runs"
              :>  Capture "run_id" Text
              :>  "submit_tool_outputs"
              :>  ReqBody '[JSON] SubmitToolOutputsToRun
              :>  Post '[JSON] RunObject
        :<|>      Capture "thread_id" Text
              :>  "runs"
              :>  Capture "run_id" Text
              :>  "cancel"
              :>  Post '[JSON] RunObject
        :<|>      Steps.API
        )
