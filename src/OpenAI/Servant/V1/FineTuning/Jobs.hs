-- | @\/v1\/fine_tuning/jobs@
module OpenAI.Servant.V1.FineTuning.Jobs
    ( -- * API
      AutoOr(..)
    , Hyperparameters(..)
    , WAndB(..)
    , Integration(..)
    , Request(..)
    , Status(..)
    , Job(..)
    , Level(..)
    , Event(..)
    , Metrics(..)
    , Checkpoint(..)
    , API
    ) where

import OpenAI.Servant.Prelude
import OpenAI.Servant.V1.Error
import OpenAI.Servant.V1.ListOf

-- | A type that can also be the string @\"auto\"@
data AutoOr a = Auto | Specific a
    deriving stock (Generic, Show)

instance FromJSON a => FromJSON (AutoOr a) where
    parseJSON "auto" = pure Auto
    parseJSON value = fmap Specific (parseJSON value)

instance ToJSON a => ToJSON (AutoOr a) where
    toJSON Auto = "auto"
    toJSON (Specific a) = toJSON a

-- | The hyperparameters used for the fine-tuning job
data Hyperparameters = Hyperparameters
    { batch_size :: Maybe (AutoOr Natural)
    , learning_rate_multiplier :: Maybe (AutoOr Double)
    , n_epochs :: Maybe (AutoOr Natural)
    } deriving stock (Generic, Show)
      deriving anyclass (FromJSON, ToJSON)

-- | The settings for your integration with Weights and
data WAndB = WAndB
    { project :: Text
    , name :: Maybe Text
    , entity :: Maybe Text
    , tags :: Maybe (Vector Text)
    } deriving stock (Generic, Show)
      deriving anyclass (FromJSON, ToJSON)

-- | An integration to enable for your fine-tuning job
data Integration = Integration_WAndB{ wandb :: WAndB }
    deriving stock (Generic, Show)

integrationOptions :: Options
integrationOptions = aesonOptions
    { sumEncoding =
        TaggedObject{ tagFieldName = "type", contentsFieldName = "" }

    , tagSingleConstructors = True

    , constructorTagModifier = stripPrefix "Integration_"
    }

instance FromJSON Integration where
    parseJSON = genericParseJSON integrationOptions

instance ToJSON Integration where
    toJSON = genericToJSON integrationOptions-- | Request body

-- | Request body
data Request = Request
    { model :: Text
    , training_file :: Text
    , hyperparameters :: Maybe Hyperparameters
    , suffix :: Maybe Text
    , validation_file :: Maybe Text
    , integrations :: Maybe (Vector Integration)
    , seed :: Maybe Integer
    } deriving stock (Generic, Show)
      deriving anyclass (ToJSON)

-- | The current status of the fine-tuning job
data Status
    = Validating_Files
    | Queued
    | Running
    | Succeeded
    | Failed
    | Cancelled
    deriving stock (Generic, Show)

instance FromJSON Status where
    parseJSON = genericParseJSON aesonOptions

-- | The fine_tuning.job object represents a fine-tuning job that has been
-- created through the API.
data Job = Job
    { id :: Text
    , created_at :: POSIXTime
    , error :: Maybe Error
    , fine_tuned_model :: Maybe Text
    , finished_at :: Maybe POSIXTime
    , job_hyperparameters :: Hyperparameters
    , job_model :: Text
    , object :: Text
    , organization_id :: Text
    , result_files :: Vector Text
    , status :: Status
    , trained_tokens :: Maybe Natural
    , job_training_file :: Text
    , job_validation_file :: Maybe Text
    , job_integrations :: Maybe (Vector Integration)
    , job_seed :: Integer
    , estimated_finish :: Maybe POSIXTime
    }
    deriving stock (Generic, Show)

instance FromJSON Job where
    parseJSON = genericParseJSON aesonOptions
        { fieldLabelModifier = stripPrefix "job_" }

-- | Log level
data Level = Info | Warn | Error
    deriving stock (Generic, Show)

instance FromJSON Level where
    parseJSON = genericParseJSON aesonOptions

-- | Fine-tuning job event object
data Event = Event
    { event_id :: Text
    , event_created_at :: POSIXTime
    , level :: Level
    , event_message :: Text
    , event_object :: Text
    } deriving stock (Generic, Show)

instance FromJSON Event where
    parseJSON = genericParseJSON aesonOptions
        { fieldLabelModifier = stripPrefix "event_" }

-- | Metrics at the step number during the fine-tuning job.
data Metrics = Metrics
    { step :: Double
    , train_loss :: Double
    , train_mean_token_accuracy :: Double
    , valid_loss :: Double
    , valid_mean_token_accuracy :: Double
    , full_valid_loss :: Double
    , full_valid_mean_token_accuracy :: Double
    } deriving stock (Generic, Show)
      deriving anyclass (FromJSON)

-- | The @fine_tuning.job.checkpoint@ object represents a model checkpoint for
-- a fine-tuning job that is ready to use
data Checkpoint = Checkpoint
    { checkpoint_id :: Text
    , checkpoint_created_at :: Text
    , fine_tuned_model_checkpoint :: Text
    , step_number :: Natural
    , metrics :: Metrics
    , fine_tuning_job_id :: Text
    , checkpoint_object :: Text
    } deriving stock (Generic, Show)

instance FromJSON Checkpoint where
    parseJSON = genericParseJSON aesonOptions
        { fieldLabelModifier = stripPrefix "checkpoint_" }

-- | API
type API =
        "fine_tuning"
    :>  "jobs"
    :>  (         ReqBody '[JSON] Request
              :>  Post '[JSON] Job
        :<|>      QueryParam "after" Text
              :>  QueryParam "limit" Natural
              :>  Get '[JSON] (ListOf Job)
        :<|>      Capture "fine_tuning_job_id" Text
              :>  "events"
              :>  QueryParam "after" Text
              :>  QueryParam "limit" Natural
              :>  Get '[JSON] (ListOf Event)
        :<|>      Capture "fine_tuning_job_id" Text
              :>  "checkpoints"
              :>  QueryParam "after" Text
              :>  QueryParam "limit" Natural
              :>  Get '[JSON] (ListOf Checkpoint)
        :<|>      Capture "fine_tuning_job_id" Text
              :>  Get '[JSON] Job
        :<|>      Capture "fine_tuning_job_id" Text
              :>  "cancel"
              :>  Post '[JSON] Job
        )
