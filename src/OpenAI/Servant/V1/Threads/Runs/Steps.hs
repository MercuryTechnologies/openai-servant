-- | @\/v1\/threads\/:thread_id\/runs\/:run_id\/steps@
module OpenAI.Servant.V1.Threads.Runs.Steps
    ( -- * Main types
      RunStepObject(..)

      -- * Other types
    , Status(..)
    , Image(..)
    , Output(..)
    , CodeInterpreter(..)
    , RankingOptions(..)
    , Content(..)
    , Result(..)
    , FileSearch(..)
    , Function(..)
    , ToolCall(..)
    , StepDetails(..)

      -- * Servant
    , API
    ) where

import OpenAI.Servant.Prelude
import OpenAI.Servant.V1.Error
import OpenAI.Servant.V1.ListOf
import OpenAI.Servant.V1.Usage

-- | The status of the run step
data Status = In_Progress | Cancelled | Failed | Completed | Expired
    deriving stock (Generic, Show)

instance FromJSON Status where
    parseJSON = genericParseJSON aesonOptions

-- | Code Interpreter image output
data Image = Image{ file_id :: Text }
    deriving stock (Generic, Show)
    deriving anyclass (FromJSON)

-- | An output from the Code Interpreter tool call
data Output = Output_Logs{ logs :: Text } | Output_Image{ image :: Image }
    deriving stock (Generic, Show)

instance FromJSON Output where
    parseJSON = genericParseJSON aesonOptions
        { sumEncoding =
            TaggedObject{ tagFieldName = "type", contentsFieldName = "" }

        , tagSingleConstructors = True

        , constructorTagModifier = stripPrefix "Output_"
        }

-- | A Code Interpreter tool call
data CodeInterpreter = CodeInterpreter
    { input :: Text
    , outputs :: Vector Output
    } deriving stock (Generic, Show)
      deriving anyclass (FromJSON)

-- | The ranking options for the file search.
data RankingOptions = RankingOptions
    { ranker :: Text
    , score_threshold :: Double
    } deriving stock (Generic, Show)
      deriving anyclass (FromJSON)

-- | The content of the result that was found
data Content = Content
    { type_ :: Text
    , text :: Text
    } deriving stock (Generic, Show)

instance FromJSON Content where
    parseJSON = genericParseJSON aesonOptions

-- | Result of the file search
data Result = Result
    { file_id :: Text
    , file_name :: Text
    , score :: Double
    , content :: Vector Content
    } deriving stock (Generic, Show)
      deriving anyclass (FromJSON)

-- | A File Search tool call
data FileSearch = FileSearch
    { ranking_options :: RankingOptions
    , results :: Vector Result
    } deriving stock (Generic, Show)
      deriving anyclass (FromJSON)

-- | The definition of the function that was called
data Function = Function
    { name :: Text
    , arguments :: Text
    , output :: Maybe Text
    } deriving (Generic, Show)
      deriving anyclass (FromJSON)

-- | A tool call the run step was involved in
data ToolCall
    = ToolCall_Code_Interpreter { id :: Text, code_interpreter :: CodeInterpreter }
    | ToolCall_File_Search { id :: Text, file_search :: Map Text FileSearch }
    | ToolCall_Function { id :: Text, function :: Function }
    deriving stock (Generic, Show)

instance FromJSON ToolCall where
    parseJSON = genericParseJSON aesonOptions
        { sumEncoding =
            TaggedObject{ tagFieldName = "type", contentsFieldName = "" }

        , tagSingleConstructors = True

        , constructorTagModifier = stripPrefix "ToolCall_"
        }

-- | The details of the run step
data StepDetails
    = Message_Creation{ message_id :: Text }
    | Tool_Calls{ tool_calls :: Vector ToolCall }
    deriving stock (Generic, Show)

instance FromJSON StepDetails where
    parseJSON = genericParseJSON aesonOptions
        { sumEncoding =
            TaggedObject{ tagFieldName = "type", contentsFieldName = "" }

        , tagSingleConstructors = True
        }

-- | Represents a step in execution of a run.
data RunStepObject = RunStepObject
    { id :: Text
    , object :: Text
    , created_at :: POSIXTime
    , assistant_id :: Text
    , thread_id :: Text
    , run_id :: Text
    , status :: Status
    , step_details :: StepDetails
    , last_error :: Maybe Error
    , expired_at :: Maybe POSIXTime
    , cancelled_at :: Maybe POSIXTime
    , failed_at :: Maybe POSIXTime
    , completed_at :: Maybe POSIXTime
    , metadata :: Map Text Text
    , usage :: Maybe (Usage CompletionTokensDetails PromptTokensDetails)
    } deriving stock (Generic, Show)
      deriving anyclass (FromJSON)

-- | Servant API
type API =
              Capture "thread_id" Text
          :>  "runs"
          :>  Capture "run_id" Text
          :>  "steps"
          :>  QueryParam "limit" Natural
          :>  QueryParam "order" Text
          :>  QueryParam "after" Text
          :>  QueryParam "before" Text
          :>  QueryParam "include[]" Text
          :>  Get '[JSON] (ListOf RunStepObject)
    :<|>      Capture "thread_id" Text
          :>  "runs"
          :>  Capture "run_id" Text
          :>  "steps"
          :>  Capture "step_id" Text
          :>  QueryParam "include[]" Text
          :>  Get '[JSON] RunStepObject
