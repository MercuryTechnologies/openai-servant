-- | The `Tool` type
module OpenAI.Servant.V1.Tool
    ( -- * Types
      Tool(..)
    , RankingOptions(..)
    , FileSearch(..)
    , Function(..)
    ) where

import OpenAI.Servant.Prelude

-- | The ranking options for the file search
data RankingOptions = RankingOptions
    { ranker :: Maybe Text
    , score_threshold :: Double
    } deriving stock (Generic, Show)
      deriving anyclass (FromJSON, ToJSON)

-- | Overrides for the file search tool
data FileSearch = FileSearch
    { max_num_results :: Maybe Natural
    , ranking_options :: Maybe RankingOptions
    } deriving stock (Generic, Show)
      deriving anyclass (FromJSON, ToJSON)

-- | The Function tool
data Function = Function
    { description :: Maybe Text
    , name :: Text
    , parameters :: Maybe Value
    , strict :: Maybe Bool
    } deriving stock (Generic, Show)
      deriving anyclass (FromJSON, ToJSON)

-- | A tool enabled on the assistant
data Tool
    = Tool_Code_Interpreter
    | Tool_File_Search{ file_search :: FileSearch }
    | Tool_Function{ function :: Function }
    deriving stock (Generic, Show)

toolOptions :: Options
toolOptions = aesonOptions
    { sumEncoding =
        TaggedObject{ tagFieldName = "type", contentsFieldName = "" }

    , tagSingleConstructors = True

    , constructorTagModifier = stripPrefix "Tool_"
    }

instance FromJSON Tool where
    parseJSON = genericParseJSON toolOptions

instance ToJSON Tool where
    toJSON = genericToJSON toolOptions