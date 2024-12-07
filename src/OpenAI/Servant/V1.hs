-- | @\/v1@
module OpenAI.Servant.V1
    ( -- * Methods
      getMethods
    , Methods(..)
      -- * API
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
import Servant.Client (ClientM)
import Servant.Multipart.Client ()

import OpenAI.Servant.V1.Audio.Transcriptions
    (CreateTranscription, Transcription)
import OpenAI.Servant.V1.FineTuning.Jobs
    (Checkpoint, CreateFineTuningJob, Event, Job)
import OpenAI.Servant.V1.Uploads
    (AddUploadPart, CompleteUpload, CreateUpload, Part, Upload)

import qualified OpenAI.Servant.V1.Audio as Audio
import qualified OpenAI.Servant.V1.Batches as Batches
import qualified OpenAI.Servant.V1.Chat.Completions as Chat.Completions
import qualified OpenAI.Servant.V1.Embeddings as Embeddings
import qualified OpenAI.Servant.V1.FineTuning.Jobs as FineTuning.Jobs
import qualified OpenAI.Servant.V1.Files as Files
import qualified OpenAI.Servant.V1.Images as Images
import qualified OpenAI.Servant.V1.Uploads as Uploads
import qualified Servant.Client as Client

-- | Get a record of API methods after providing an API token
getMethods
    :: Text
    -- ^ API token
    -> Methods
getMethods token = Methods{..}
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
      ) = Client.client (Proxy @API) authorization

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
    { createSpeech :: CreateSpeech -> ClientM ByteString
    , createTranscription :: CreateTranscription -> ClientM Transcription
    , createTranslation :: CreateTranslation -> ClientM Translation
    , createChatCompletion :: CreateChatCompletion -> ClientM ChatCompletion
    , createEmbeddings :: CreateEmbeddings -> ClientM (ListOf Embedding)
    , createFineTuningJob :: CreateFineTuningJob -> ClientM Job
    , listFineTuningJobs
        :: Maybe Text
        -- ^ after
        -> Maybe Natural
        -- ^ limit
        -> ClientM (ListOf Job)
    , listFineTuningEvents
        :: Text
        -- ^ Job ID
        -> Maybe Text
        -- ^ after
        -> Maybe Natural
        -- ^ limit
        -> ClientM (ListOf Event)
    , listFineTuningCheckpoints
        :: Text
        -- ^ Job ID
        -> Maybe Text
        -- ^ after
        -> Maybe Natural
        -- ^ limit
        -> ClientM (ListOf Checkpoint)
    , retrieveFineTuningJob
        :: Text
        -- ^ Job ID
        -> ClientM FineTuning.Jobs.Job
    , cancelFineTuning
        :: Text
        -- ^ Job ID
        -> ClientM FineTuning.Jobs.Job
    , createBatch :: CreateBatch -> ClientM Batch
    , retrieveBatch
        :: Text
        -- ^ Batch ID
        -> ClientM Batch
    , cancelBatch
        :: Text
        -- ^ Batch ID
        -> ClientM Batch
    , listBatch
        :: Maybe Text
        -- ^ after
        -> Maybe Natural
        -- ^ limit
        -> ClientM (ListOf Batch)
    , uploadFile :: UploadFile -> ClientM File
    , listFiles
        :: Maybe Files.Purpose
        -- ^
        -> Maybe Natural
        -- ^ limit
        -> Maybe Files.Order
        -- ^
        -> Maybe Text
        -- ^ after
        -> ClientM (ListOf File)
    , retrieveFile
        :: Text
        -- ^ File ID
        -> ClientM Files.File
    , deleteFile
        :: Text
        -- ^ File ID
        -> ClientM Status
    , retrieveFileContent
        :: Text
        -- ^ File ID
        -> ClientM ByteString
    , createUpload
        :: CreateUpload -> ClientM (Upload (Maybe Void))
    , addUploadPart
        :: Text
        -- ^ Upload ID
        -> AddUploadPart
        -- ^
        -> ClientM Part
    , completeUpload
        :: Text
        -- ^ Upload ID
        -> CompleteUpload
        -- ^
        -> ClientM (Upload Files.File)
    , cancelUpload
        :: Text
        -- ^ Upload ID
        -> ClientM (Upload (Maybe Void))
    , createImage :: CreateImage -> ClientM (ListOf Image)
    , createImageEdit :: CreateImageEdit -> ClientM (ListOf Image)
    , createImageVariation :: CreateImageVariation -> ClientM (ListOf Image)
    }

-- | API
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
        )
