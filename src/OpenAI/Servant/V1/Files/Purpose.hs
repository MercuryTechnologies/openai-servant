-- | The purpose for an uploaded file
module OpenAI.Servant.V1.Files.Purpose
    ( -- * API
      Purpose(..)
    ) where

import OpenAI.Servant.Prelude

-- | The intended purpose of the uploaded file.
data Purpose
    = Assistants
    | Assistants_Output
    | Batch
    | Batch_Output
    | Fine_Tune
    | Fine_Tune_Results
    | Vision
    deriving stock (Generic, Show)

instance FromJSON Purpose where
    parseJSON = genericParseJSON aesonOptions
        { constructorTagModifier = fix . labelModifier
        }
      where
        fix "fine_tune" = "fine-tune"
        fix "fine_tune_results" = "fine-tune-results"
        fix string = string

instance ToHttpApiData Purpose where
    toUrlPiece Assistants = "assistants"
    toUrlPiece Assistants_Output = "assistants"
    toUrlPiece Batch = "batch"
    toUrlPiece Batch_Output = "batch_output"
    toUrlPiece Fine_Tune = "fine-tune"
    toUrlPiece Fine_Tune_Results = "fine-tune-results"
    toUrlPiece Vision = "vision"
