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
import OpenAI.Servant.V1.Audio.Speech (CreateSpeech)
import OpenAI.Servant.V1.Audio.Translations (CreateTranslation, Translation)
import OpenAI.Servant.V1.Chat.Completions (ChatCompletion, CreateChatCompletion)
import OpenAI.Servant.V1.Embeddings (CreateEmbeddings, Embedding)
import OpenAI.Servant.V1.Batches (CreateBatch, Batch)
import OpenAI.Servant.V1.DeletionStatus (DeletionStatus)
import OpenAI.Servant.V1.Files (File, UploadFile)
import OpenAI.Servant.V1.Images.Image (Image)
import OpenAI.Servant.V1.Images.Generations (CreateImage)
import OpenAI.Servant.V1.Images.Edits (CreateImageEdit)
import OpenAI.Servant.V1.Images.Variations (CreateImageVariation)
import OpenAI.Servant.V1.ListOf (ListOf(..))
import OpenAI.Servant.V1.Models (Model)
import OpenAI.Servant.V1.Moderations (CreateModeration, Moderation)
import OpenAI.Servant.V1.Order (Order)
import Servant.Client (ClientEnv)
import Servant.Multipart.Client ()

import OpenAI.Servant.V1.Assistants
    (Assistant, CreateAssistant, ModifyAssistant)
import OpenAI.Servant.V1.Audio.Transcriptions
    (CreateTranscription, Transcription)
import OpenAI.Servant.V1.FineTuning.Jobs
    (Checkpoint, CreateFineTuningJob, Event, Job)
import OpenAI.Servant.V1.Uploads
    (AddUploadPart, CompleteUpload, CreateUpload, Part, Upload)

import qualified Control.Exception as Exception
import qualified Data.Text as Text
import qualified Network.HTTP.Client.TLS as TLS
import qualified OpenAI.Servant.V1.Assistants as Assistants
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
      :<|>  createEmbeddings_
      :<|>  (     createFineTuningJob
            :<|>  listFineTuningJobs_
            :<|>  listFineTuningEvents_
            :<|>  listFineTuningCheckpoints_
            :<|>  retrieveFineTuningJob
            :<|>  cancelFineTuning
            )
      :<|>  (     createBatch
            :<|>  retrieveBatch
            :<|>  cancelBatch
            :<|>  listBatch_
            )
      :<|>  (     uploadFile_
            :<|>  listFiles_
            :<|>  retrieveFile
            :<|>  deleteFile
            :<|>  retrieveFileContent
            )
      :<|>  (     createImage_
            :<|>  createImageEdit_
            :<|>  createImageVariation_
            )
      :<|>  (     createUpload
            :<|>  addUploadPart_
            :<|>  completeUpload
            :<|>  cancelUpload
            )
      :<|>  (     listModels_
            :<|>  retrieveModel
            :<|>  deleteModel
            )
      :<|>  (     createModeration
            )
      :<|>  (   (\x -> x "assistants=v2")
            ->  (     createAssistant
                :<|>  listAssistants_
                :<|>  retrieveAssistant
                :<|>  modifyAssistant
                :<|>  deleteAssistant
                )
            )
      ) = Client.hoistClient @API Proxy run (Client.client @API Proxy) authorization

    run :: Client.ClientM a -> IO a
    run clientM = do
        result <- Client.runClientM clientM clientEnv
        case result of
            Left exception -> Exception.throwIO exception
            Right a -> return a

    toVector :: IO (ListOf a) -> IO (Vector a)
    toVector = fmap adapt
      where
        adapt List{ data_ } = data_

    createTranscription a = createTranscription_ (boundary, a)
    createTranslation a = createTranslation_ (boundary, a)
    createEmbeddings a = toVector (createEmbeddings_ a)
    listFineTuningJobs a b = toVector (listFineTuningJobs_ a b)
    listFineTuningEvents a b c = toVector (listFineTuningEvents_ a b c)
    listFineTuningCheckpoints a b c =
        toVector (listFineTuningCheckpoints_ a b c)
    listBatch a b = toVector (listBatch_ a b)
    uploadFile a = uploadFile_ (boundary, a)
    listFiles a b c d = toVector (listFiles_ a b c d)
    addUploadPart a b = addUploadPart_ a (boundary, b)
    createImage a = toVector (createImage_ a)
    createImageEdit a = toVector (createImageEdit_ (boundary, a))
    createImageVariation a = toVector (createImageVariation_ (boundary, a))
    listModels = toVector listModels_
    listAssistants a b c d = toVector (listAssistants_ a b c d)

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
    , createEmbeddings :: CreateEmbeddings -> IO (Vector Embedding)
    , createFineTuningJob :: CreateFineTuningJob -> IO Job
    , listFineTuningJobs
        :: Maybe Text
        -- ^ after
        -> Maybe Natural
        -- ^ limit
        -> IO (Vector Job)
    , listFineTuningEvents
        :: Text
        -- ^ Job ID
        -> Maybe Text
        -- ^ after
        -> Maybe Natural
        -- ^ limit
        -> IO (Vector Event)
    , listFineTuningCheckpoints
        :: Text
        -- ^ Job ID
        -> Maybe Text
        -- ^ after
        -> Maybe Natural
        -- ^ limit
        -> IO (Vector Checkpoint)
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
        -> IO (Vector Batch)
    , uploadFile :: UploadFile -> IO File
    , listFiles
        :: Maybe Files.Purpose
        -- ^
        -> Maybe Natural
        -- ^ limit
        -> Maybe Order
        -- ^
        -> Maybe Text
        -- ^ after
        -> IO (Vector File)
    , retrieveFile
        :: Text
        -- ^ File ID
        -> IO Files.File
    , deleteFile
        :: Text
        -- ^ File ID
        -> IO DeletionStatus
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
    , createImage :: CreateImage -> IO (Vector Image)
    , createImageEdit :: CreateImageEdit -> IO (Vector Image)
    , createImageVariation :: CreateImageVariation -> IO (Vector Image)
    , listModels :: IO (Vector Model)
    , retrieveModel
        :: Text
        -- ^ Model ID
        -> IO Model
    , deleteModel
        :: Text
        -- ^ Model ID
        -> IO Models.DeletionStatus
    , createModeration :: CreateModeration -> IO Moderation
    , createAssistant :: CreateAssistant -> IO Assistant
    , listAssistants
        :: Maybe Natural
        -- ^ limit
        -> Maybe Order
        -- ^ order
        -> Maybe Text
        -- ^ after
        -> Maybe Text
        -- ^ before
        -> IO (Vector Assistant)
    , retrieveAssistant
        :: Text
        -- ^ Assistant ID
        -> IO Assistant
    , modifyAssistant
        :: Text
        -- ^ Assistant ID
        -> ModifyAssistant
        -> IO Assistant
    , deleteAssistant
        :: Text
        -- ^ Assistant ID
        -> IO DeletionStatus
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
        :<|>  Assistants.API
        )
