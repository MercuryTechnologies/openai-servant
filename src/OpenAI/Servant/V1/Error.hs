-- | Error information
module OpenAI.Servant.V1.Error
    ( -- * Types
      Error(..)
    ) where

import OpenAI.Servant.Prelude

-- | More information on the cause of the failure.
--
-- NOTE: OpenAPI API's says that the `code` and `message` fields are required,
-- but in practice the `Error` record can be present with all fields omitted,
-- so they are all marked optional (`Maybe`) here
data Error = Error
    { code :: Maybe Text
    , message :: Maybe Text
    , param :: Maybe Text
    } deriving stock (Generic, Show)
      deriving anyclass (FromJSON)
