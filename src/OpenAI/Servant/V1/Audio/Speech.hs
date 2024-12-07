-- | @\/v1\/audio\/speech@
module OpenAI.Servant.V1.Audio.Speech
    ( -- * API
      Voice(..)
    , Format(..)
    , CreateSpeech(..)
    , ContentType(..)
    , API
    ) where

import OpenAI.Servant.Prelude

-- | The voice to use when generating the audio
--
-- Previews of the voices are available in the
-- [Text to speech guide](https://platform.openai.com/docs/guides/text-to-speech#voice-options).
data Voice = Alloy | Echo | Fable | Onyx | Nova | Shimmer
    deriving stock (Bounded, Enum, Generic, Show)

instance ToJSON Voice where
    toJSON = genericToJSON aesonOptions

-- | The format to audio in
data Format = MP3 | Opus | AAC | FLAC | WAV | PCM
    deriving stock (Bounded, Enum, Generic, Show)

instance ToJSON Format where
    toJSON = genericToJSON aesonOptions

-- | Request body for @\/v1\/audio\/speech@
data CreateSpeech = CreateSpeech
    { model :: Text
    , input :: Text
    , voice :: Voice
    , response_format :: Maybe Format
    , speed :: Maybe Double
    } deriving stock (Generic, Show)
      deriving anyclass (ToJSON)

-- | Content type
data ContentType = ContentType

instance Accept ContentType where
    contentTypes _ =
            "audio/mpeg"
        :|  [ "audio/flac"
            , "audio/wav"
            , "audio/aac"
            , "audio/opus"
            , "audio/pcm"
            ]

instance MimeUnrender ContentType ByteString where
    mimeUnrender _ bytes = Right bytes

-- | API
type API =
    "speech" :> ReqBody '[JSON] CreateSpeech :> Post '[ContentType] ByteString
