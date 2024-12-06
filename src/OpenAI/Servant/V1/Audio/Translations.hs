-- | @\/v1\/audio\/translations@
--
-- To simplify things, this only supports the @verbose_json@ response format
module OpenAI.Servant.V1.Audio.Translations
    ( -- * API
      Request(..)
    , Response
    , API
    ) where

import OpenAI.Servant.Prelude as OpenAI.Servant.Prelude

import qualified Data.Text as Text

-- | Request body
data Request = Request
    { file :: FilePath
    , model :: Text
    , prompt :: Maybe Text
    , temperature :: Maybe Double
    } deriving stock (Generic, Show)

instance ToMultipart Tmp Request where
    toMultipart Request{..} = MultipartData{..}
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

-- | Response body
data Response = Response
    { text :: Text
    } deriving stock (Generic, Show)
      deriving anyclass (FromJSON)

-- | API
type API =
        "translations" :> MultipartForm Tmp Request :> Post '[JSON] Response
