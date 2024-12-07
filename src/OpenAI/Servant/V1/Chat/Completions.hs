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
    , CreateChatCompletion(..)
    , _CreateChatCompletion
    , FinishReason(..)
    , Token(..)
    , LogProbs(..)
    , Choice(..)
    , CompletionTokensDetails(..)
    , PromptTokensDetails(..)
    , Usage(..)
    , ChatCompletion(..)
    , API
    ) where

import OpenAI.Servant.Prelude
import Prelude hiding (id)

-- | Data about a previous audio response from the model.
-- [Learn more](https://platform.openai.com/docs/guides/audio)
data AudioData = AudioData{ id :: Text }
    deriving stock (Generic, Show)
    deriving anyclass (FromJSON, ToJSON)

-- | A called function
data CalledFunction = CalledFunction{ name :: Text, arguments :: Text }
    deriving stock (Generic, Show)
    deriving anyclass (FromJSON, ToJSON)

-- | Tools called by the model
data ToolCall = ToolCall_Function
    { id :: Text
    , function :: CalledFunction
    } deriving stock (Generic, Show)

toolCallOptions :: Options
toolCallOptions = aesonOptions
    { sumEncoding =
        TaggedObject{ tagFieldName = "type", contentsFieldName = "" }

    , tagSingleConstructors = True

    , constructorTagModifier = stripPrefix "ToolCall_"
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
data Prediction = Content{ content :: Text }
    deriving stock (Generic, Show)

instance ToJSON Prediction where
    toJSON = genericToJSON aesonOptions
        { sumEncoding =
            TaggedObject{ tagFieldName = "type", contentsFieldName = "" }

        , tagSingleConstructors = True
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
    { description :: Maybe Text
    , name :: Text
    , schema :: Maybe Value
    , strict :: Maybe Bool
    } deriving stock (Generic, Show)
      deriving anyclass (ToJSON)

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
data ServiceTier = Auto | Default
    deriving stock (Generic, Show)

instance FromJSON ServiceTier where
    parseJSON = genericParseJSON aesonOptions

instance ToJSON ServiceTier where
    toJSON = genericToJSON aesonOptions

-- | A callable function
data CallableFunction = CallableFunction
    { description :: Maybe Text
    , name :: Text
    , parameters :: Maybe Value
    , strict :: Maybe Bool
    } deriving stock (Generic, Show)
      deriving anyclass (ToJSON)

-- | Tools callable by the model
data Tool = Tool_Function
    { function :: CallableFunction
    } deriving stock (Generic, Show)

instance ToJSON Tool where
    toJSON = genericToJSON aesonOptions
        { sumEncoding =
            TaggedObject{ tagFieldName = "type", contentsFieldName = "" }

        , tagSingleConstructors = True

        , constructorTagModifier = stripPrefix "Tool_"
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

-- | Request body for @\/v1\/chat\/completions@
data CreateChatCompletion = CreateChatCompletion
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

instance ToJSON CreateChatCompletion where
    toJSON = genericToJSON aesonOptions

-- | Default `CreateChatCompletion`
_CreateChatCompletion :: CreateChatCompletion
_CreateChatCompletion = CreateChatCompletion
    { store = Nothing
    , metadata = Nothing
    , frequency_penalty = Nothing
    , logit_bias = Nothing
    , logprobs = Nothing
    , top_logprobs = Nothing
    , max_completion_tokens = Nothing
    , n = Nothing
    , modalities = Nothing
    , prediction = Nothing
    , audio = Nothing
    , presence_penalty = Nothing
    , response_format = Nothing
    , seed = Nothing
    , service_tier = Nothing
    , stop = Nothing
    , temperature = Nothing
    , top_p = Nothing
    , tools = Nothing
    , tool_choice = Nothing
    , parallel_tool_calls = Nothing
    , user = Nothing
    }

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
    , top_logprobs :: Maybe (Vector Token)
    } deriving stock (Generic, Show)
      deriving anyclass (FromJSON)

-- | Log probability information for the choice
data LogProbs = LogProbs
    { content :: Maybe (Vector Token)
    , refusal :: Maybe (Vector Token)
    } deriving stock (Generic, Show)
      deriving anyclass (FromJSON)

-- | A chat completion choice
data Choice = Choice
    { finish_reason :: Text
    , index :: Natural
    , message :: Message
    , logprobs :: Maybe LogProbs
    } deriving stock (Generic, Show)
      deriving anyclass (FromJSON)

-- | Breakdown of tokens used in a completion
data CompletionTokensDetails = CompletionTokensDetails
    { accepted_prediction_tokens :: Natural
    , audio_tokens :: Natural
    , reasoning_tokens :: Natural
    , rejected_prediction_tokens :: Natural
    } deriving stock (Generic, Show)
      deriving anyclass (FromJSON)

-- | Breakdown of tokens used in the prompt
data PromptTokensDetails = PromptTokensDetails
    { audio_tokens :: Natural
    , cached_tokens :: Natural
    } deriving stock (Generic, Show)
      deriving anyclass (FromJSON)

-- | Usage statistics for the completion request
data Usage = Usage
    { completion_tokens :: Natural
    , prompt_tokens :: Natural
    , total_tokens :: Natural
    , completion_tokens_details :: CompletionTokensDetails
    , prompt_tokens_details :: PromptTokensDetails
    } deriving stock (Generic, Show)
      deriving anyclass (FromJSON)

-- | ChatCompletion body
data ChatCompletion = ChatCompletion
    { id :: Text
    , choices :: Vector Choice
    , created :: POSIXTime
    , model :: Text
    , service_tier :: Maybe ServiceTier
    , system_fingerprint :: Text
    , object :: Text
    , usage :: Usage
    } deriving stock (Generic, Show)
      deriving anyclass (FromJSON)

-- | API
type API =
        "chat"
    :>  "completions"
    :>  ReqBody '[JSON] CreateChatCompletion
    :>  Post '[JSON] ChatCompletion
