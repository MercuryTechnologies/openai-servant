-- | @\/v1@
module OpenAI.Servant.V1
    ( -- * Methods
      getMethods
    , Methods(..)
      -- * API
    , API
    ) where

import Data.Proxy (Proxy(..))
import OpenAI.Servant.Prelude
import OpenAI.Servant.V1.ListOf (ListOf)
import Servant.Client (ClientM)
import Servant.Multipart.Client ()

import qualified OpenAI.Servant.V1.Audio as Audio
import qualified OpenAI.Servant.V1.Audio.Speech as Audio.Speech
import qualified OpenAI.Servant.V1.Audio.Transcriptions as Audio.Transcriptions
import qualified OpenAI.Servant.V1.Audio.Translations as Audio.Translations
import qualified OpenAI.Servant.V1.Batches as Batches
import qualified OpenAI.Servant.V1.Chat.Completions as Chat.Completions
import qualified OpenAI.Servant.V1.Embeddings as Embeddings
import qualified OpenAI.Servant.V1.FineTuning.Jobs as FineTuning.Jobs
import qualified OpenAI.Servant.V1.Files as Files
import qualified OpenAI.Servant.V1.Images as Images
import qualified OpenAI.Servant.V1.Images.Generations as Generations
import qualified OpenAI.Servant.V1.Images.Edits as Edits
import qualified OpenAI.Servant.V1.Images.Image as Image
import qualified OpenAI.Servant.V1.Images.Variations as Variations
import qualified OpenAI.Servant.V1.Uploads as Uploads
import qualified Servant.Client as Client

-- | Get a record of API methods after providing an API token
getMethods
    :: Text
    -- ^ API token
    -> Methods
getMethods authorization = Methods{..}
  where
    (       (     createSpeech
            :<|>  createTranscription
            :<|>  createTranslation
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
      :<|>  (     uploadFile
            :<|>  listFiles
            :<|>  retrieveFile
            :<|>  deleteFile
            :<|>  retrieveFileContent
            )
      :<|>  (     createImage
            :<|>  createImageEdit
            :<|>  createImageVariation
            )
      :<|>  (     createUpload
            :<|>  addUploadPart
            :<|>  completeUpload
            :<|>  cancelUpload
            )
      ) = Client.client (Proxy @API) authorization

-- | API methods
data Methods = Methods
    { createSpeech
        :: Audio.Speech.Request -> ClientM Audio.Speech.Response
    , createTranscription
        :: (ByteString, Audio.Transcriptions.Request) -> ClientM Audio.Transcriptions.Response
    , createTranslation
        :: (ByteString, Audio.Translations.Request) -> ClientM Audio.Translations.Response
    , createChatCompletion
        :: Chat.Completions.Request -> ClientM Chat.Completions.Response
    , createEmbeddings
        :: Embeddings.Request -> ClientM (ListOf Embeddings.Embedding)
    , createFineTuningJob
        :: FineTuning.Jobs.Request -> ClientM FineTuning.Jobs.Job
    , listFineTuningJobs
        :: Maybe Text
        -- ^ after
        -> Maybe Natural
        -- ^ limit
        -> ClientM (ListOf FineTuning.Jobs.Job)
    , listFineTuningEvents
        :: Text
        -- ^ Job ID
        -> Maybe Text
        -- ^ after
        -> Maybe Natural
        -- ^ limit
        -> ClientM (ListOf FineTuning.Jobs.Event)
    , listFineTuningCheckpoints
        :: Text
        -- ^ Job ID
        -> Maybe Text
        -- ^ after
        -> Maybe Natural
        -- ^ limit
        -> ClientM (ListOf FineTuning.Jobs.Checkpoint)
    , retrieveFineTuningJob
        :: Text
        -- ^ Job ID
        -> ClientM FineTuning.Jobs.Job
    , cancelFineTuning
        :: Text
        -- ^ Job ID
        -> ClientM FineTuning.Jobs.Job
    , createBatch
        :: Batches.Request -> ClientM Batches.Batch
    , retrieveBatch
        :: Text
        -- ^ Batch ID
        -> ClientM Batches.Batch
    , cancelBatch
        :: Text
        -- ^ Batch ID
        -> ClientM Batches.Batch
    , listBatch
        :: Maybe Text
        -- ^ after
        -> Maybe Natural
        -- ^ limit
        -> ClientM (ListOf Batches.Batch)
    , uploadFile
        :: (ByteString, Files.Request) -> ClientM Files.File
    , listFiles
        :: Maybe Files.Purpose
        -- ^
        -> Maybe Natural
        -- ^ limit
        -> Maybe Files.Order
        -- ^
        -> Maybe Text
        -- ^ after
        -> ClientM (ListOf Files.File)
    , retrieveFile
        :: Text
        -- ^ File ID
        -> ClientM Files.File
    , deleteFile
        :: Text
        -- ^ File ID
        -> ClientM Files.Status
    , retrieveFileContent
        :: Text
        -- ^ File ID
        -> ClientM ByteString
    , createUpload
        :: Uploads.CreateUpload -> ClientM (Uploads.Upload (Maybe Void))
    , addUploadPart
        :: Text
        -- ^ Upload ID
        -> (ByteString, Uploads.AddUploadPart)
        -- ^
        -> ClientM Uploads.Part
    , completeUpload
        :: Text
        -- ^ Upload ID
        -> Uploads.CompleteUpload
        -- ^
        -> ClientM (Uploads.Upload Files.File)
    , cancelUpload
        :: Text
        -- ^ Upload ID
        -> ClientM (Uploads.Upload (Maybe Void))
    , createImage
        :: Generations.CreateImage -> ClientM (ListOf Image.Image)
    , createImageEdit
        :: (ByteString, Edits.CreateImageEdit) -> ClientM (ListOf Image.Image)
    , createImageVariation
        :: (ByteString, Variations.CreateImageVariation)
        -> ClientM (ListOf Image.Image)
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
