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
import OpenAI.Servant.V1.Embeddings (CreateEmbeddings, EmbeddingObject)
import OpenAI.Servant.V1.Batches (CreateBatch, BatchObject)
import OpenAI.Servant.V1.DeletionStatus (DeletionStatus)
import OpenAI.Servant.V1.Files (FileObject, UploadFile)
import OpenAI.Servant.V1.Images.Image (ImageObject)
import OpenAI.Servant.V1.Images.Generations (CreateImage)
import OpenAI.Servant.V1.Images.Edits (CreateImageEdit)
import OpenAI.Servant.V1.Images.Variations (CreateImageVariation)
import OpenAI.Servant.V1.ListOf (ListOf(..))
import OpenAI.Servant.V1.Models (ModelObject)
import OpenAI.Servant.V1.Moderations (CreateModeration, Moderation)
import OpenAI.Servant.V1.Order (Order)
import OpenAI.Servant.V1.Threads (CreateThread, ModifyThread, Thread)
import Servant.Client (ClientEnv)
import Servant.Multipart.Client ()

import OpenAI.Servant.V1.Assistants
    (Assistant, CreateAssistant, ModifyAssistant)
import OpenAI.Servant.V1.Audio.Transcriptions
    (CreateTranscription, TranscriptionObject)
import OpenAI.Servant.V1.Audio.Translations
    (CreateTranslation, TranslationObject)
import OpenAI.Servant.V1.Chat.Completions
    (ChatCompletionObject, CreateChatCompletion)
import OpenAI.Servant.V1.FineTuning.Jobs
    (CheckpointObject, CreateFineTuningJob, EventObject, JobObject)
import OpenAI.Servant.V1.Uploads
    (AddUploadPart, CompleteUpload, CreateUpload, PartObject, UploadObject)

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
import qualified OpenAI.Servant.V1.Threads as Threads
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
      :<|>  (   (\x -> x "assistants=v2")
            ->  (     createThread
                :<|>  retrieveThread
                :<|>  modifyThread
                :<|>  deleteThread
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
    , createTranscription :: CreateTranscription -> IO TranscriptionObject
    , createTranslation :: CreateTranslation -> IO TranslationObject
    , createChatCompletion :: CreateChatCompletion -> IO ChatCompletionObject
    , createEmbeddings :: CreateEmbeddings -> IO (Vector EmbeddingObject)
    , createFineTuningJob :: CreateFineTuningJob -> IO JobObject
    , listFineTuningJobs
        :: Maybe Text
        -- ^ after
        -> Maybe Natural
        -- ^ limit
        -> IO (Vector JobObject)
    , listFineTuningEvents
        :: Text
        -- ^ Job ID
        -> Maybe Text
        -- ^ after
        -> Maybe Natural
        -- ^ limit
        -> IO (Vector EventObject)
    , listFineTuningCheckpoints
        :: Text
        -- ^ Job ID
        -> Maybe Text
        -- ^ after
        -> Maybe Natural
        -- ^ limit
        -> IO (Vector CheckpointObject)
    , retrieveFineTuningJob
        :: Text
        -- ^ Job ID
        -> IO JobObject
    , cancelFineTuning
        :: Text
        -- ^ Job ID
        -> IO JobObject
    , createBatch :: CreateBatch -> IO BatchObject
    , retrieveBatch
        :: Text
        -- ^ Batch ID
        -> IO BatchObject
    , cancelBatch
        :: Text
        -- ^ Batch ID
        -> IO BatchObject
    , listBatch
        :: Maybe Text
        -- ^ after
        -> Maybe Natural
        -- ^ limit
        -> IO (Vector BatchObject)
    , uploadFile :: UploadFile -> IO FileObject
    , listFiles
        :: Maybe Files.Purpose
        -- ^
        -> Maybe Natural
        -- ^ limit
        -> Maybe Order
        -- ^
        -> Maybe Text
        -- ^ after
        -> IO (Vector FileObject)
    , retrieveFile
        :: Text
        -- ^ File ID
        -> IO FileObject
    , deleteFile
        :: Text
        -- ^ File ID
        -> IO DeletionStatus
    , retrieveFileContent
        :: Text
        -- ^ File ID
        -> IO ByteString
    , createUpload
        :: CreateUpload -> IO (UploadObject (Maybe Void))
    , addUploadPart
        :: Text
        -- ^ Upload ID
        -> AddUploadPart
        -- ^
        -> IO PartObject
    , completeUpload
        :: Text
        -- ^ Upload ID
        -> CompleteUpload
        -- ^
        -> IO (UploadObject FileObject)
    , cancelUpload
        :: Text
        -- ^ Upload ID
        -> IO (UploadObject (Maybe Void))
    , createImage :: CreateImage -> IO (Vector ImageObject)
    , createImageEdit :: CreateImageEdit -> IO (Vector ImageObject)
    , createImageVariation :: CreateImageVariation -> IO (Vector ImageObject)
    , listModels :: IO (Vector ModelObject)
    , retrieveModel
        :: Text
        -- ^ Model ID
        -> IO ModelObject
    , deleteModel
        :: Text
        -- ^ Model ID
        -> IO DeletionStatus
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
    , createThread :: CreateThread -> IO Thread
    , retrieveThread
        :: Text
        -- ^ Thread ID
        -> IO Thread
    , modifyThread
        :: Text
        -- ^ Thread ID
        -> ModifyThread
        -- ^
        -> IO Thread
    , deleteThread
        :: Text
        -- ^ Thread ID
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
        :<|>  Threads.API
        )
