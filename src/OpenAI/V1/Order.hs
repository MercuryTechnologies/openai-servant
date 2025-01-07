-- | The `Order` type
module OpenAI.V1.Order
    ( -- * Types
      Order(..)
    ) where

import OpenAI.Prelude

-- | Sort order by the @created_at@ timestamp of the objects
data Order = Desc | Asc

instance ToHttpApiData Order where
    toUrlPiece Desc = "desc"
    toUrlPiece Asc = "asc"
