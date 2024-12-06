-- | @\/v1\/audio\/transcriptions@
--
-- To simplify things, this only supports the @verbose_json@ response format
-- and also only supports the @segment@ granularity
module OpenAI.Servant.V1.Audio.Transcriptions
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
    , language :: Maybe Text
    , prompt :: Maybe Text
    , temperature :: Maybe Double
    } deriving stock (Generic, Show)

instance ToMultipart Tmp Request where
    toMultipart Request{..} = MultipartData{..}
      where
        inputs =
                input "model" model
            <>  foldMap (input "language") language
            <>  foldMap (input "prompt") prompt
            <>  input "response_format" "verbose_json"
            <>  foldMap (input "temperature" . renderRealFloat) temperature
            <>  input "timestamp_granularities[]" "segment"

        files = [ FileData{..} ]
          where
            fdInputName = "file"
            fdFileName = Text.pack file
            fdFileCType = "audio/" <> getExtension file
            fdPayload = file

data Segment = Segment
    { id :: Integer
    , seek :: Integer
    , start :: Double
    , end :: Double
    , text :: Text
    , tokens :: Vector Prelude.Word
    , temperature :: Double
    , avg_logprob :: Double
    , compression_ratio :: Double
    , no_speech_prob :: Double
    } deriving stock (Generic, Show)
      deriving anyclass (FromJSON)

-- | Response body
data Response = Response
    { language :: Maybe Text
    , duration :: Maybe Double
    , text :: Text
    , segments :: Vector Segment
    } deriving stock (Generic, Show)
      deriving anyclass (FromJSON)

-- | API
type API =
        "transcriptions" :> MultipartForm Tmp Request :> Post '[JSON] Response
