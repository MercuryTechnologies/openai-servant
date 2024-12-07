-- | @\/v1@
module OpenAI.Servant.V1
    ( -- * Methods
      getClientEnv
    , makeMethods
    , Methods(..)
      -- * Servant
    , API
    ) where

import Data.ByteString.Char8 ()
import Data.Proxy (Proxy(..))
import OpenAI.Servant.Prelude
import OpenAI.Servant.V1.ListOf (ListOf)
import OpenAI.Servant.V1.Audio.Speech (CreateSpeech)
import OpenAI.Servant.V1.Audio.Translations (CreateTranslation, Translation)
import OpenAI.Servant.V1.Chat.Completions (ChatCompletion, CreateChatCompletion)
import OpenAI.Servant.V1.Embeddings (CreateEmbeddings, Embedding)
import OpenAI.Servant.V1.Batches (CreateBatch, Batch)
import OpenAI.Servant.V1.Files (File, Status, UploadFile)
import OpenAI.Servant.V1.Images.Image (Image)
import OpenAI.Servant.V1.Images.Generations (CreateImage)
import OpenAI.Servant.V1.Images.Edits (CreateImageEdit)
import OpenAI.Servant.V1.Images.Variations (CreateImageVariation)
import OpenAI.Servant.V1.Models (Model)
import OpenAI.Servant.V1.Moderations (CreateModeration, Moderation)
import Servant.Client (ClientEnv)
import Servant.Multipart.Client ()

import OpenAI.Servant.V1.Audio.Transcriptions
    (CreateTranscription, Transcription)
import OpenAI.Servant.V1.FineTuning.Jobs
    (Checkpoint, CreateFineTuningJob, Event, Job)
import OpenAI.Servant.V1.Uploads
    (AddUploadPart, CompleteUpload, CreateUpload, Part, Upload)

import qualified Control.Exception as Exception
import qualified Data.Text as Text
import qualified Network.HTTP.Client.TLS as TLS
import qualified OpenAI.Servant.V1.Audio as Audio
import qualified OpenAI.Servant.V1.Batches as Batches
import qualified OpenAI.Servant.V1.Chat.Completions as Chat.Completions
import qualified OpenAI.Servant.V1.Embeddings as Embeddings
import qualified OpenAI.Servant.V1.FineTuning.Jobs as FineTuning.Jobs
import qualified OpenAI.Servant.V1.Files as Files
import qualified OpenAI.Servant.V1.Images as Images
import qualified OpenAI.Servant.V1.Models as Models
import qualified OpenAI.Servant.V1.Moderations as Moderations
import qualified OpenAI.Servant.V1.Uploads as Uploads
import qualified Servant.Client as Client

-- | Convenient utility to get a `ClientEnv` for the most common use case
getClientEnv
    :: Text
    -- ^ Base URL for API
    -> IO ClientEnv
getClientEnv baseUrlText = do
    baseUrl <- Client.parseBaseUrl (Text.unpack baseUrlText)
    manager <- TLS.newTlsManager
    pure (Client.mkClientEnv manager baseUrl)

-- | Get a record of API methods after providing an API token
makeMethods
    :: ClientEnv
    -- ^
    -> Text
    -- ^ API token
    -> Methods
makeMethods clientEnv token = Methods{..}
  where
    authorization = "Bearer " <> token

    (       (     createSpeech
            :<|>  createTranscription_
            :<|>  createTranslation_
                    )
      :<|>  createChatCompletion
      :<|>  createEmbeddings
      :<|>  (     createFineTuningJob
            :<|>  listFineTuningJobs
            :<|>  listFineTuningEvents
            :<|>  listFineTuningCheckpoints
            :<|>  retrieveFineTuningJob
            :<|>  cancelFineTuning
            )
      :<|>  (     createBatch
            :<|>  retrieveBatch
            :<|>  cancelBatch
            :<|>  listBatch
            )
      :<|>  (     uploadFile_
            :<|>  listFiles
            :<|>  retrieveFile
            :<|>  deleteFile
            :<|>  retrieveFileContent
            )
      :<|>  (     createImage
            :<|>  createImageEdit_
            :<|>  createImageVariation_
            )
      :<|>  (     createUpload
            :<|>  addUploadPart_
            :<|>  completeUpload
            :<|>  cancelUpload
            )
      :<|>  (     listModels
            :<|>  retrieveModel
            :<|>  deleteModel
            )
      :<|>  (     createModeration
            )
      ) = Client.hoistClient @API Proxy run (Client.client @API Proxy) authorization

    run :: Client.ClientM a -> IO a
    run clientM = do
        result <- Client.runClientM clientM clientEnv
        case result of
            Left exception -> Exception.throwIO exception
            Right a -> return a

    createTranscription a = createTranscription_ (boundary, a)
    createTranslation a = createTranslation_ (boundary, a)
    uploadFile a = uploadFile_ (boundary, a)
    addUploadPart a b = addUploadPart_ a (boundary, b)
    createImageEdit a = createImageEdit_ (boundary, a)
    createImageVariation a = createImageVariation_ (boundary, a)

-- | Hard-coded boundary to simplify the user-experience
--
-- I don't understand why `multipart-servant-client` insists on generating a
-- fresh boundary for each request (or why it doesn't handle that for you)
boundary :: ByteString
boundary = "j3qdD3XtDVjvva8IIqoBzHQAYwCenObtPMkxAFnylwFyU5xffWKoYrY"

-- | API methods
data Methods = Methods
    { createSpeech :: CreateSpeech -> IO ByteString
    , createTranscription :: CreateTranscription -> IO Transcription
    , createTranslation :: CreateTranslation -> IO Translation
    , createChatCompletion :: CreateChatCompletion -> IO ChatCompletion
    , createEmbeddings :: CreateEmbeddings -> IO (ListOf Embedding)
    , createFineTuningJob :: CreateFineTuningJob -> IO Job
    , listFineTuningJobs
        :: Maybe Text
        -- ^ after
        -> Maybe Natural
        -- ^ limit
        -> IO (ListOf Job)
    , listFineTuningEvents
        :: Text
        -- ^ Job ID
        -> Maybe Text
        -- ^ after
        -> Maybe Natural
        -- ^ limit
        -> IO (ListOf Event)
    , listFineTuningCheckpoints
        :: Text
        -- ^ Job ID
        -> Maybe Text
        -- ^ after
        -> Maybe Natural
        -- ^ limit
        -> IO (ListOf Checkpoint)
    , retrieveFineTuningJob
        :: Text
        -- ^ Job ID
        -> IO FineTuning.Jobs.Job
    , cancelFineTuning
        :: Text
        -- ^ Job ID
        -> IO FineTuning.Jobs.Job
    , createBatch :: CreateBatch -> IO Batch
    , retrieveBatch
        :: Text
        -- ^ Batch ID
        -> IO Batch
    , cancelBatch
        :: Text
        -- ^ Batch ID
        -> IO Batch
    , listBatch
        :: Maybe Text
        -- ^ after
        -> Maybe Natural
        -- ^ limit
        -> IO (ListOf Batch)
    , uploadFile :: UploadFile -> IO File
    , listFiles
        :: Maybe Files.Purpose
        -- ^
        -> Maybe Natural
        -- ^ limit
        -> Maybe Files.Order
        -- ^
        -> Maybe Text
        -- ^ after
        -> IO (ListOf File)
    , retrieveFile
        :: Text
        -- ^ File ID
        -> IO Files.File
    , deleteFile
        :: Text
        -- ^ File ID
        -> IO Status
    , retrieveFileContent
        :: Text
        -- ^ File ID
        -> IO ByteString
    , createUpload
        :: CreateUpload -> IO (Upload (Maybe Void))
    , addUploadPart
        :: Text
        -- ^ Upload ID
        -> AddUploadPart
        -- ^
        -> IO Part
    , completeUpload
        :: Text
        -- ^ Upload ID
        -> CompleteUpload
        -- ^
        -> IO (Upload Files.File)
    , cancelUpload
        :: Text
        -- ^ Upload ID
        -> IO (Upload (Maybe Void))
    , createImage :: CreateImage -> IO (ListOf Image)
    , createImageEdit :: CreateImageEdit -> IO (ListOf Image)
    , createImageVariation :: CreateImageVariation -> IO (ListOf Image)
    , listModels :: IO (ListOf Model)
    , retrieveModel
        :: Text
        -- ^ Model ID
        -> IO Model
    , deleteModel
        :: Text
        -- ^ Model ID
        -> IO Models.DeletionStatus
    , createModeration :: CreateModeration -> IO Moderation
    }

-- | Servant API
type API
    =   Header' [ Required, Strict ] "Authorization" Text
    :>  "v1"
    :>  (     Audio.API
        :<|>  Chat.Completions.API
        :<|>  Embeddings.API
        :<|>  FineTuning.Jobs.API
        :<|>  Batches.API
        :<|>  Files.API
        :<|>  Images.API
        :<|>  Uploads.API
        :<|>  Models.API
        :<|>  Moderations.API
        )
