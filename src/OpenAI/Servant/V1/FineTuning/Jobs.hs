-- | @\/v1\/fine_tuning/jobs@
module OpenAI.Servant.V1.FineTuning.Jobs
    ( -- * API
      AutoOr(..)
    , Hyperparameters(..)
    , WAndB(..)
    , Integration(..)
    , Request(..)
    , Error(..)
    , Status(..)
    , Job(..)
    , API
    ) where

import OpenAI.Servant.Prelude

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

-- | For fine-tuning jobs that have @failed@, this will contain more
-- information on the cause of the failure.
--
-- NOTE: OpenAPI API's says that the `code` and `message` fields are required,
-- but in practice the `Error` record can be present with all fields omitted,
-- so they are all marked optional (`Maybe`) here
data Error = Error
    { code :: Maybe Text
    , message :: Maybe Text
    , param :: Maybe Text
    } deriving stock (Generic, Show)
      deriving anyclass (FromJSON)

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

-- | API
type API =
        "jobs"
    :>  (     ReqBody '[JSON] Request :> Post '[JSON] Job
        :<|>  Capture "fine_tuning_job_id" Text :> "cancel" :> Post '[JSON] Job
        )
