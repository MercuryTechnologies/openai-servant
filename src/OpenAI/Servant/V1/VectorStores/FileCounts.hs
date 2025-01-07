-- | The `FileCounts` type
module OpenAI.Servant.V1.VectorStores.FileCounts
    ( -- * Main types
      FileCounts(..)
    ) where

import OpenAI.Servant.Prelude

-- | File counts
data FileCounts = FileCounts
    { in_progress :: Natural
    , completed :: Natural
    , failed :: Natural
    , cancelled :: Natural
    , total :: Natural
    } deriving stock (Generic, Show)
      deriving anyclass (FromJSON)
