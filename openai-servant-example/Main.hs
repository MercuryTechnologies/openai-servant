{-# LANGUAGE BlockArguments        #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE NamedFieldPuns        #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE OverloadedLists       #-}

module Main where

import Control.Monad.IO.Class (liftIO)
import Data.Foldable (traverse_)
import Data.Text (Text)
import Servant.Client (ClientM)
import OpenAI.Servant.V1 (Methods(..))

import OpenAI.Servant.V1.Chat.Completions
    (ChatCompletion(..), Choice(..), CreateChatCompletion(..), Message(..))

import qualified Control.Exception as Exception
import qualified Data.Text as Text
import qualified Data.Text.IO as Text.IO
import qualified Network.HTTP.Client.TLS as TLS
import qualified OpenAI.Servant.V1 as OpenAI
import qualified Servant.Client as Client
import qualified System.Environment as Environment

contents :: Message -> Text
contents System{ content } = content
contents User{ content } = content
contents Assistant{ assistant_content = Nothing } = ""
contents Assistant{ assistant_content = Just content } = content
contents Tool{ content } = content

main :: IO ()
main = do
    manager <- TLS.newTlsManager

    baseUrl <- Client.parseBaseUrl "https://api.openai.com"

    let clientEnv = Client.mkClientEnv manager baseUrl

    key <- Environment.getEnv "OPENAI_KEY"

    let Methods{ createChatCompletion } = OpenAI.getMethods (Text.pack key)

    line <- Text.IO.getLine

    let run :: ClientM a -> IO a
        run clientM = do
            result <- Client.runClientM clientM clientEnv

            case result of
                Left clientError -> Exception.throwIO clientError
                Right a -> return a

    run do
        ChatCompletion{ choices } <- createChatCompletion CreateChatCompletion
            { messages = [ User{ content = line, name = Nothing } ]
            , model = "gpt-4o-mini"
            , store = Nothing
            , metadata = Nothing
            , frequency_penalty = Nothing
            , logit_bias = Nothing
            , logprobs = Nothing
            , top_logprobs = Nothing
            , max_completion_tokens = Nothing
            , n = Nothing
            , modalities = Nothing
            , prediction = Nothing
            , audio = Nothing
            , presence_penalty = Nothing
            , response_format = Nothing
            , seed = Nothing
            , service_tier = Nothing
            , stop = Nothing
            , temperature = Nothing
            , top_p = Nothing
            , tools = Nothing
            , tool_choice = Nothing
            , parallel_tool_calls = Nothing
            , user = Nothing
            }

        let display Choice{ message } = Text.IO.putStrLn (contents message)

        liftIO (traverse_ display choices)
