-- | @\/v1\/images\/variations@
module OpenAI.Servant.V1.Images.Variations
    ( -- * API
      CreateImageVariation(..)
    , API
    ) where

import OpenAI.Servant.Prelude
import OpenAI.Servant.V1.Images.Image
import OpenAI.Servant.V1.Images.ResponseFormat
import OpenAI.Servant.V1.ListOf

import qualified Data.Text as Text

-- | Request body for @\/v1\/images\/variations@
data CreateImageVariation = CreateImageVariation
    { image :: FilePath
    , model :: Maybe Text
    , n :: Maybe Natural
    , response_format :: Maybe ResponseFormat
    , size :: Maybe Text
    , user :: Maybe Text
    } deriving stock (Generic, Show)

instance ToMultipart Tmp CreateImageVariation where
    toMultipart CreateImageVariation{..} = MultipartData{..}
      where
        inputs =
                foldMap (input "model") model
            <>  foldMap (input "n" . renderIntegral) n
            <>  foldMap (input "response_format" . toUrlPiece) response_format
            <>  foldMap (input "size") size
            <>  foldMap (input "user") user

        files = [ FileData{..} ]
          where
            fdInputName = "image"
            fdFileName = Text.pack image
            fdFileCType = "image/" <> getExtension image
            fdPayload = image

-- | API
type API =
        "variations"
    :>  MultipartForm Tmp CreateImageVariation
    :>  Post '[JSON] (ListOf Image)
