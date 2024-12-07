-- | @\/v1\/audio\/translations@
--
-- To simplify things, this only supports the @verbose_json@ response format
module OpenAI.Servant.V1.Audio.Translations
    ( -- * API
      CreateTranslation(..)
    , Translation(..)
    , API
    ) where

import OpenAI.Servant.Prelude as OpenAI.Servant.Prelude

import qualified Data.Text as Text

-- | Request body for @\/v1\/audio\/translations@
data CreateTranslation = CreateTranslation
    { file :: FilePath
    , model :: Text
    , prompt :: Maybe Text
    , temperature :: Maybe Double
    } deriving stock (Generic, Show)

instance ToMultipart Tmp CreateTranslation where
    toMultipart CreateTranslation{..} = MultipartData{..}
      where
        inputs =
                input "model" model
            <>  foldMap (input "prompt") prompt
            <>  input "response_format" "verbose_json"
            <>  foldMap (input "temperature" . renderRealFloat) temperature

        files = [ FileData{..} ]
          where
            fdInputName = "file"
            fdFileName = Text.pack file
            fdFileCType = "audio/" <> getExtension file
            fdPayload = file

-- | Represents a transcription response returned by model, based on the
-- provided input.
data Translation = Translation
    { text :: Text
    } deriving stock (Generic, Show)
      deriving anyclass (FromJSON)

-- | API
type API =
        "translations"
    :>  MultipartForm Tmp CreateTranslation
    :>  Post '[JSON] Translation
