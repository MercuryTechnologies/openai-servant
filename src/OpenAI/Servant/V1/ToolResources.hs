-- | The `ToolResources` type
module OpenAI.Servant.V1.ToolResources
    ( -- * Main types
      ToolResources(..)

      -- * Other types
    , CodeInterpreterResources(..)
    , Static(..)
    , ChunkingStrategy(..)
    , VectorStore(..)
    , FileSearchResources(..)
    ) where

import OpenAI.Servant.Prelude
import OpenAI.Servant.V1.AutoOr

-- | Resources for the code search tool
data CodeInterpreterResources = CodeInterpreterResources
    { file_ids :: Maybe (Vector Text)
    } deriving stock (Generic, Show)
      deriving anyclass (FromJSON, ToJSON)

-- | Static chunking strategy
data Static = Static
    { max_chunk_size_tokens :: Natural
    , chunk_overlap_tokens :: Natural
    } deriving stock (Generic, Show)
      deriving anyclass (FromJSON, ToJSON)

-- | The chunking strategy used to chunk the file(s)
data ChunkingStrategy = ChunkingStrategy_Static{ static :: Static }
    deriving stock (Generic, Show)

chunkingStrategyOptions :: Options
chunkingStrategyOptions = aesonOptions
    { sumEncoding =
        TaggedObject{ tagFieldName = "type", contentsFieldName = "" }

    , tagSingleConstructors = True

    , constructorTagModifier = stripPrefix "ChunkingStrategy_"
    }

instance ToJSON ChunkingStrategy where
    toJSON = genericToJSON chunkingStrategyOptions

instance FromJSON ChunkingStrategy where
    parseJSON = genericParseJSON chunkingStrategyOptions

-- | A helper to create a vector store with file_ids and attach it to this
-- assistant
data VectorStore = VectorStore
    { file_ids :: Maybe (Vector Text)
    , chunking_strategy :: Maybe (AutoOr ChunkingStrategy)
    } deriving stock (Generic, Show)
      deriving anyclass (FromJSON, ToJSON)

-- | Resources for the file search tool
data FileSearchResources = FileSearchResources
    { vector_store_ids :: Maybe (Vector Text)
    , vector_stores :: Maybe (Vector VectorStore)
    } deriving stock (Generic, Show)
      deriving anyclass (FromJSON, ToJSON)

-- | A set of resources that are used by the assistant's tools
data ToolResources = ToolResources
    { code_interpreter :: Maybe CodeInterpreterResources
    , file_search :: Maybe FileSearchResources
    } deriving stock (Generic, Show)
      deriving anyclass (FromJSON, ToJSON)
