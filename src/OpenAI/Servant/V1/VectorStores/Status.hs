-- | The `Status` type
module OpenAI.Servant.V1.VectorStores.Status
    ( -- * Main types
      Status(..)
    ) where

import OpenAI.Servant.Prelude

-- | The status of the vector store file
data Status = In_Progress | Completed | Cancelled | Failed
    deriving stock (Generic, Show)

instance FromJSON Status where
    parseJSON = genericParseJSON aesonOptions

instance ToHttpApiData Status where
    toUrlPiece In_Progress = "in_progress"
    toUrlPiece Completed = "completed"
    toUrlPiece Cancelled = "cancelled"
    toUrlPiece Failed = "failed"
