-- | @\/v1\/chat\/completions@
--
-- Streaming results are not yet supported
module OpenAI.Servant.V1.Chat.Completions
    ( -- * API
      AudioData(..)
    , CalledFunction(..)
    , ToolCall(..)
    , Message(..)
    , Modality(..)
    , Prediction(..)
    , Voice(..)
    , AudioFormat(..)
    , AudioParameters(..)
    , JSONSchema(..)
    , ResponseFormat(..)
    , ServiceTier(..)
    , CallableFunction(..)
    , Tool(..)
    , ToolChoice(..)
    , Request(..)
    , FinishReason(..)
    , Token(..)
    , LogProbs(..)
    , Choice(..)
    , CompletionTokensDetails(..)
    , PromptTokensDetails(..)
    , Usage(..)
    , Response
    , API
    ) where

import OpenAI.Servant.Prelude
import Prelude hiding (id)

-- | Data about a previous audio response from the model.
-- [Learn more](https://platform.openai.com/docs/guides/audio)
data AudioData = AudioData{ audio_id :: Text }
    deriving stock (Generic, Show)

audioDataOptions :: Options
audioDataOptions = aesonOptions{ fieldLabelModifier = stripPrefix "audio_" }

instance FromJSON AudioData where
    parseJSON = genericParseJSON audioDataOptions

instance ToJSON AudioData where
    toJSON = genericToJSON audioDataOptions

-- | A called function
data CalledFunction = CalledFunction
    { called_name :: Text
    , called_arguments :: Text
    } deriving stock (Generic, Show)

calledFunctionOptions :: Options
calledFunctionOptions = aesonOptions
    { fieldLabelModifier = stripPrefix "called_" }

instance FromJSON CalledFunction where
    parseJSON = genericParseJSON calledFunctionOptions

instance ToJSON CalledFunction where
    toJSON = genericToJSON calledFunctionOptions

-- | Tools called by the model
data ToolCall = ToolCall_Function
    { called_id :: Text
    , called_function :: CalledFunction
    } deriving stock (Generic, Show)

toolCallOptions :: Options
toolCallOptions = aesonOptions
    { sumEncoding =
        TaggedObject{ tagFieldName = "type", contentsFieldName = "" }

    , tagSingleConstructors = True

    , constructorTagModifier = stripPrefix "ToolCall_"

    , fieldLabelModifier = stripPrefix "called_"
    }

instance ToJSON ToolCall where
    toJSON = genericToJSON toolCallOptions

instance FromJSON ToolCall where
    parseJSON = genericParseJSON toolCallOptions

-- | A message from the conversation so far
data Message
    = System
        { content :: Text
        , name :: Maybe Text
        }
    | User
        { content :: Text
        , name :: Maybe Text
        }
    | Assistant
        { assistant_content :: Maybe Text
        , refusal :: Maybe Text
        , name :: Maybe Text
        , assistant_audio :: Maybe AudioData
        , tool_calls :: Maybe (Vector ToolCall)
        }
    | Tool
        { content :: Text
        , tool_call_id :: Text
        }
    deriving stock (Generic, Show)

messageOptions :: Options
messageOptions = aesonOptions
    { sumEncoding =
        TaggedObject{ tagFieldName = "role", contentsFieldName = "" }

    , tagSingleConstructors = True

    , fieldLabelModifier = stripPrefix "assistant_"
    }

instance FromJSON Message where
    parseJSON = genericParseJSON messageOptions

instance ToJSON Message where
    toJSON = genericToJSON messageOptions

-- | Output types that you would like the model to generate for this request
data Modality = Text | Audio
    deriving stock (Generic, Show)

instance ToJSON Modality where
    toJSON = genericToJSON aesonOptions

-- | Configuration for a
-- [Predicted Output](https://platform.openai.com/docs/guides/predicted-outputs),
-- which can greatly improve response times when large parts of the model
-- response are known ahead of time. This is most common when you are
-- regenerating a file with only minor changes to most of the content
data Prediction = Content{ prediction_content :: Text }
    deriving stock (Generic, Show)

instance ToJSON Prediction where
    toJSON = genericToJSON aesonOptions
        { sumEncoding =
            TaggedObject{ tagFieldName = "type", contentsFieldName = "" }

        , tagSingleConstructors = True

        , fieldLabelModifier = stripPrefix "prediction_"
        }

-- | The voice the model uses to respond
data Voice = Ash | Ballad | Coral | Sage | Verse
    deriving stock (Generic, Show)

instance ToJSON Voice where
    toJSON = genericToJSON aesonOptions

-- | Specifies the output audio format
data AudioFormat = WAV | MP3 | FLAC | Opus | PCM16
    deriving stock (Generic, Show)

instance ToJSON AudioFormat where
    toJSON = genericToJSON aesonOptions

-- | Parameters for audio output
data AudioParameters = AudioParameters
    { voice :: Voice
    , format :: AudioFormat
    } deriving stock (Generic, Show)
      deriving anyclass (ToJSON)

-- | Setting to { "type": "json_schema", "json_schema": {...} } enables
-- Structured Outputs which ensures the model will match your supplied JSON
-- schema. Learn more in the
-- [Structured Outputs](https://platform.openai.com/docs/guides/structured-outputs) guide
data JSONSchema = JSONSchema
    { schema_description :: Maybe Text
    , schema_name :: Text
    , schema :: Maybe Value
    , schema_strict :: Maybe Bool
    } deriving stock (Generic, Show)

instance ToJSON JSONSchema where
    toJSON = genericToJSON aesonOptions
        { fieldLabelModifier = stripPrefix "schema_" }

-- | An object specifying the format that the model must output
data ResponseFormat
    = ResponseFormat_Text
    | JSON_Object
    | JSON_Schema{ json_schema :: JSONSchema }
    deriving stock (Generic, Show)

instance ToJSON ResponseFormat where
    toJSON = genericToJSON aesonOptions
        { sumEncoding =
            TaggedObject{ tagFieldName = "type", contentsFieldName = "" }

        , tagSingleConstructors = True

        , constructorTagModifier = stripPrefix "ResponseFormat_"
        }

-- | Specifies the latency tier to use for processing the request
data ServiceTier = ServiceTier_Auto | ServiceTier_Default
    deriving stock (Generic, Show)

serviceTierOptions :: Options
serviceTierOptions = aesonOptions
    { constructorTagModifier = stripPrefix "ServiceTier_" }

instance FromJSON ServiceTier where
    parseJSON = genericParseJSON serviceTierOptions

instance ToJSON ServiceTier where
    toJSON = genericToJSON serviceTierOptions

-- | A callable function
data CallableFunction = CallableFunction
    { callable_description :: Maybe Text
    , callable_name :: Text
    , parameters :: Maybe Value
    , strict :: Maybe Bool
    } deriving stock (Generic, Show)

instance ToJSON CallableFunction where
    toJSON = genericToJSON aesonOptions
        { fieldLabelModifier = stripPrefix "callable_" }

-- | Tools callable by the model
data Tool = Tool_Function
    { callable_function :: CallableFunction
    } deriving stock (Generic, Show)

instance ToJSON Tool where
    toJSON = genericToJSON aesonOptions
        { sumEncoding =
            TaggedObject{ tagFieldName = "type", contentsFieldName = "" }

        , tagSingleConstructors = True

        , constructorTagModifier = stripPrefix "Tool_"

        , fieldLabelModifier = stripPrefix "callable_"
        }

-- | Controls which (if any) tool is called by the model
data ToolChoice
    = ToolChoiceNone
    | ToolChoiceAuto
    | ToolChoiceRequired
    | ToolChoiceTool Tool
    deriving stock (Generic, Show)

instance ToJSON ToolChoice where
    toJSON ToolChoiceNone = "none"
    toJSON ToolChoiceAuto = "auto"
    toJSON ToolChoiceRequired = "required"
    toJSON (ToolChoiceTool tool) = toJSON tool

-- | Request body
data Request = Request
    { messages :: Vector Message
    , model :: Text
    , store :: Maybe Bool
    , metadata :: Maybe (Map Text Text)
    , frequency_penalty :: Maybe Double
    , logit_bias :: Maybe (Map Word Int)
    , logprobs :: Maybe Bool
    , top_logprobs :: Maybe Word
    , max_completion_tokens :: Maybe Natural
    , n :: Maybe Natural
    , modalities :: Maybe (Vector Modality)
    , prediction :: Maybe Prediction
    , audio :: Maybe AudioParameters
    , presence_penalty :: Maybe Double
    , response_format :: Maybe ResponseFormat
    , seed :: Maybe Integer
    , service_tier :: Maybe ServiceTier
    , stop :: Maybe (Vector Text)
    , temperature :: Maybe Double
    , top_p :: Maybe Double
    , tools :: Maybe (Vector Tool)
    , tool_choice :: Maybe ToolChoice
    , parallel_tool_calls :: Maybe Bool
    , user :: Maybe Text
    } deriving stock (Generic, Show)

instance ToJSON Request where
    toJSON = genericToJSON aesonOptions

-- | The reason the model stopped generating tokens
data FinishReason
    = Stop
    | Length
    | Content_Filter
    | Tool_Calls
    deriving stock (Generic, Show)

instance FromJSON FinishReason where
    parseJSON = genericParseJSON messageOptions

-- | Message tokens with log probability information
data Token = Token
    { token :: Text
    , logprob :: Double
    , bytes :: Maybe (Vector Word8)
    , token_top_logprobs :: Maybe (Vector Token)
    } deriving stock (Generic, Show)

instance FromJSON Token where
    parseJSON = genericParseJSON aesonOptions
        { fieldLabelModifier = stripPrefix "token_" }

-- | Log probability information for the choice
data LogProbs = LogProbs
    { logProbs_content :: Maybe (Vector Token)
    , logProbs_refusal :: Maybe (Vector Token)
    } deriving stock (Generic, Show)

instance FromJSON LogProbs where
    parseJSON = genericParseJSON aesonOptions
        { fieldLabelModifier = stripPrefix "logProbs_"
        }

-- | A chat completion choice
data Choice = Choice
    { finish_reason :: Text
    , index :: Natural
    , message :: Message
    , choice_logprobs :: Maybe LogProbs
    } deriving stock (Generic, Show)

instance FromJSON Choice where
    parseJSON = genericParseJSON aesonOptions
        { fieldLabelModifier = stripPrefix "choice_" }

-- | Breakdown of tokens used in a completion
data CompletionTokensDetails = CompletionTokensDetails
    { accepted_prediction_tokens :: Natural
    , completion_audio_tokens :: Natural
    , reasoning_tokens :: Natural
    , rejected_prediction_tokens :: Natural
    } deriving stock (Generic, Show)

instance FromJSON CompletionTokensDetails where
    parseJSON = genericParseJSON aesonOptions
        { fieldLabelModifier = stripPrefix "completion_" }

-- | Breakdown of tokens used in the prompt
data PromptTokensDetails = PromptTokensDetails
    { prompt_audio_tokens :: Natural
    , cached_tokens :: Natural
    } deriving stock (Generic, Show)

instance FromJSON PromptTokensDetails where
    parseJSON = genericParseJSON aesonOptions
        { fieldLabelModifier = stripPrefix "prompt_" }

-- | Usage statistics for the completion request
data Usage = Usage
    { completion_tokens :: Natural
    , prompt_tokens :: Natural
    , total_tokens :: Natural
    , completion_tokens_details :: CompletionTokensDetails
    , prompt_tokens_details :: PromptTokensDetails
    } deriving stock (Generic, Show)
      deriving anyclass (FromJSON)

-- | Response body
data Response = Response
    { id :: Text
    , choices :: Vector Choice
    , created :: POSIXTime
    , response_model :: Text
    , response_service_tier :: Maybe ServiceTier
    , system_fingerprint :: Text
    , object :: Text
    , usage :: Usage
    } deriving stock (Generic, Show)

instance FromJSON Response where
    parseJSON = genericParseJSON aesonOptions
        { fieldLabelModifier = stripPrefix "response_" }

-- | API
type API =
    "chat" :> "completions" :> ReqBody '[JSON] Request :> Post '[JSON] Response
