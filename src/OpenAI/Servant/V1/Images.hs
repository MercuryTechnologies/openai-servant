-- | @\/v1\/images@
module OpenAI.Servant.V1.Images
    ( -- * API
      API
    ) where

import OpenAI.Servant.Prelude

import qualified OpenAI.Servant.V1.Images.Generations as Generations
import qualified OpenAI.Servant.V1.Images.Edits as Edits
import qualified OpenAI.Servant.V1.Images.Variations as Variations

-- | API
type API = "images" :> (Generations.API :<|> Edits.API :<|> Variations.API)