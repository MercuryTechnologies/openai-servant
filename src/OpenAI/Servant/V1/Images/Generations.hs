-- | @\/v1\/images\/generations@
module OpenAI.Servant.V1.Images.Generations
    ( -- * API
      Quality(..)
    , Style(..)
    , CreateImage(..)
    , API
    ) where

import OpenAI.Servant.Prelude
import OpenAI.Servant.V1.Images.Image
import OpenAI.Servant.V1.Images.ResponseFormat
import OpenAI.Servant.V1.ListOf

-- | The quality of the image that will be generated
data Quality = Standard | HD
    deriving stock (Generic, Show)

instance ToJSON Quality where
    toJSON = genericToJSON aesonOptions

-- | The style of the generated images
data Style = Vivid | Natural
    deriving stock (Generic, Show)

instance ToJSON Style where
    toJSON = genericToJSON aesonOptions

-- | Requesty body for @\/v1/images/generations@
data CreateImage = CreateImage
    { prompt :: Text
    , model :: Maybe Text
    , n :: Maybe Natural
    , quality :: Maybe Quality
    , response_format :: Maybe ResponseFormat
    , size :: Maybe Text
    , style :: Maybe Style
    , user :: Maybe Text
    } deriving stock (Generic, Show)

instance ToJSON CreateImage where
    toJSON = genericToJSON aesonOptions

-- | * API
type API =
    "generations" :> ReqBody '[JSON] CreateImage :> Post '[JSON] (ListOf Image)
