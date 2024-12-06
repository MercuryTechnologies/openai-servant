{-# LANGUAGE BlockArguments    #-}
{-# LANGUAGE NamedFieldPuns    #-}
{-# LANGUAGE OverloadedLists   #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}
{-# LANGUAGE TypeApplications  #-}

module Main where

import Servant.Client (ClientM)
import OpenAI.Servant.V1 (Methods(..))

import qualified Control.Exception as Exception
import qualified Data.Text as Text
import qualified Network.HTTP.Client as HTTP.Client
import qualified Network.HTTP.Client.TLS as TLS
import qualified OpenAI.Servant.V1 as V1
import qualified OpenAI.Servant.V1.Audio.Speech as Speech
import qualified OpenAI.Servant.V1.Audio.Transcriptions as Transcriptions
import qualified OpenAI.Servant.V1.Audio.Translations as Translations
import qualified OpenAI.Servant.V1.Batches as Batches
import qualified OpenAI.Servant.V1.Chat.Completions as Completions
import qualified OpenAI.Servant.V1.Embeddings as Embeddings
import qualified OpenAI.Servant.V1.Files as Files
import qualified OpenAI.Servant.V1.FineTuning.Jobs as Jobs
import qualified Servant.Client as Client
import qualified System.Environment as Environment
import qualified Servant.Multipart.Client as Multipart.Client
import qualified Test.Tasty as Tasty
import qualified Test.Tasty.HUnit as HUnit

main :: IO ()
main = do
    let managerSettings = TLS.tlsManagerSettings
            { HTTP.Client.managerResponseTimeout =
                HTTP.Client.responseTimeoutNone
            }

    manager <- TLS.newTlsManagerWith managerSettings

    baseUrl <- Client.parseBaseUrl "https://api.openai.com"

    let clientEnv = Client.mkClientEnv manager baseUrl

    key <- Environment.getEnv "OPENAI_KEY"

    boundary <- Multipart.Client.genBoundary

    let authorization = "Bearer " <> Text.pack key

    let user = "openai Haskell package"
    let chatModel = "gpt-4o-mini"

    let Methods{..} = V1.getMethods authorization

    let run :: ClientM a -> IO a
        run clientM = do
            result <- Client.runClientM clientM clientEnv
            case result of
                Left clientError -> Exception.throwIO clientError
                Right a          -> return a

    -- Test each format to make sure we're handling each possible content type
    -- correctly
    let speechTest format =
            HUnit.testCase ("Create speech - " <> show format) do
                run do
                    _ <- createSpeech Speech.Request
                        { Speech.model = "tts-1"
                        , Speech.input = "Hello, world!"
                        , Speech.voice = Speech.Nova
                        , Speech.response_format = Just format
                        , Speech.speed = Just 1.0
                        }

                    return ()

    let speechTests = do
            format <- [ minBound .. maxBound ]
            return (speechTest format)

    let transcriptionTest =
            HUnit.testCase "Create transcription" do
                run do
                    _ <- createTranscription
                        ( boundary
                        , Transcriptions.Request
                            { Transcriptions.file =
                                "tasty/data/v1/audio/preamble.wav"
                            , Transcriptions.model =
                                "whisper-1"
                            , Transcriptions.language =
                                Just "en"
                            , Transcriptions.prompt =
                                Nothing
                            , Transcriptions.temperature =
                                Just 0
                            }
                        )

                    return ()

    let translationTest =
            HUnit.testCase "Create translation" do
                run do
                    _ <- createTranslation
                        ( boundary
                        , Translations.Request
                            { Translations.file =
                                "tasty/data/v1/audio/preamble.wav"
                            , Translations.model =
                                "whisper-1"
                            , Translations.prompt =
                                Nothing
                            , Translations.temperature =
                                Just 0
                            }
                        )

                    return ()

    let completionsMinimalTest =
            HUnit.testCase "Create chat completion - minimal" do
                run do
                    _ <- createChatCompletion Completions.Request
                        { Completions.messages =
                            [ Completions.User
                                { Completions.content = "Hello, world!"
                                , Completions.name = Nothing
                                }
                            ]
                        , Completions.model = chatModel
                        , Completions.store = Nothing
                        , Completions.metadata = Nothing
                        , Completions.frequency_penalty = Nothing
                        , Completions.logit_bias = Nothing
                        , Completions.logprobs = Nothing
                        , Completions.top_logprobs = Nothing
                        , Completions.max_completion_tokens = Nothing
                        , Completions.n = Nothing
                        , Completions.modalities = Nothing
                        , Completions.prediction = Nothing
                        , Completions.audio = Nothing
                        , Completions.presence_penalty = Nothing
                        , Completions.response_format = Nothing
                        , Completions.seed = Nothing
                        , Completions.service_tier = Nothing
                        , Completions.stop = Nothing
                        , Completions.temperature = Nothing
                        , Completions.top_p = Nothing
                        , Completions.tools = Nothing
                        , Completions.tool_choice = Nothing
                        , Completions.parallel_tool_calls = Nothing
                        , Completions.user = Nothing
                        }

                    return ()

    let completionsMaximalTest =
            HUnit.testCase "Create chat completion - maximal" do
                run do
                    _ <- createChatCompletion Completions.Request
                        { Completions.messages =
                            [ Completions.User
                                { Completions.content = "Hello, world!"
                                , Completions.name = Just "gabby"
                                }
                            , Completions.Assistant
                                { Completions.assistant_content = Nothing
                                , Completions.refusal = Nothing
                                , Completions.name = Just "Ada"
                                , Completions.assistant_audio = Nothing
                                , Completions.tool_calls = Just
                                    [ Completions.ToolCall_Function
                                        { Completions.called_id =
                                            "call_bzE95mjMMFqeanfY2sL6Sdir"
                                        , Completions.called_function =
                                            Completions.CalledFunction
                                              { Completions.called_name =
                                                  "hello"
                                              , Completions.called_arguments =
                                                  "{}"
                                              }
                                        }
                                    ]
                                }
                            , Completions.Tool
                                { Completions.content = "Hello, world!"
                                , Completions.tool_call_id =
                                    "call_bzE95mjMMFqeanfY2sL6Sdir"
                                }
                            ]
                        , Completions.model = chatModel
                        , Completions.store = Just False
                        , Completions.metadata = Nothing
                        , Completions.frequency_penalty = Just 0
                        , Completions.logit_bias = Just mempty
                        , Completions.logprobs = Just True
                        , Completions.top_logprobs = Just 1
                        , Completions.max_completion_tokens = Just 1024
                        , Completions.n = Just 1
                        , Completions.modalities = Just [ Completions.Text ]
                        , Completions.prediction = Nothing
                        , Completions.audio = Nothing
                        , Completions.presence_penalty = Just 0
                        , Completions.response_format =
                            Just Completions.ResponseFormat_Text
                        , Completions.seed = Just 0
                        , Completions.service_tier =
                            Just Completions.ServiceTier_Auto
                        , Completions.stop = Just [ ">>>" ]
                        , Completions.temperature = Just 1
                        , Completions.top_p = Just 1
                        , Completions.tools = Just
                            [ Completions.Tool_Function
                                { Completions.callable_function =
                                    Completions.CallableFunction
                                      { Completions.callable_description =
                                          Just "Use the hello command line tool"
                                      , Completions.callable_name =
                                          "hello"
                                      , Completions.parameters = Nothing
                                      , Completions.strict = Just False
                                      }
                                }
                            ]
                        , Completions.tool_choice =
                            Just Completions.ToolChoiceAuto
                        , Completions.parallel_tool_calls =
                            Just True
                        , Completions.user = Just user
                        }

                    return ()

    let embeddingsTest = do
            HUnit.testCase "Create embedding" do
                run do
                    _ <- createEmbeddings Embeddings.Request
                        { Embeddings.input = "Hello, world!"
                        , Embeddings.model = "text-embedding-3-small"
                        , Embeddings.encoding_format = Just Embeddings.Float
                        , Embeddings.dimensions = Just 1024
                        , Embeddings.user = Just user
                        }

                    return ()

    let fineTuningTest = do
            HUnit.testCase "Fine-tuning and File operations - maximal" do
                run do
                    trainingFile <- uploadFile
                        ( boundary
                        , Files.Request
                            { Files.file =
                                "tasty/data/v1/fine_tuning/jobs/training_data.jsonl"
                            , Files.purpose = Files.Fine_Tune
                            }
                        )

                    validationFile <- uploadFile
                        ( boundary
                        , Files.Request
                            { Files.file =
                                "tasty/data/v1/fine_tuning/jobs/validation_data.jsonl"
                            , Files.purpose = Files.Fine_Tune
                            }
                        )

                    _ <- retrieveFile (Files.id trainingFile)

                    _ <- retrieveFileContent (Files.id trainingFile)

                    _ <- listFiles (Just Files.Fine_Tune) (Just 10000) (Just Files.Asc) Nothing

                    job <- createFineTuningJob Jobs.Request
                        { Jobs.model = "gpt-4o-mini-2024-07-18"
                        , Jobs.training_file = Files.id trainingFile
                        , Jobs.hyperparameters = Just
                              Jobs.Hyperparameters
                                  { Jobs.batch_size =
                                      Just Jobs.Auto
                                  , Jobs.learning_rate_multiplier =
                                      Just Jobs.Auto
                                  , Jobs.n_epochs =
                                      Just Jobs.Auto
                                  }
                        , Jobs.suffix = Just "haskell-openai"
                        , Jobs.validation_file = Just (Files.id validationFile)
                        , Jobs.integrations = Just []
                        , Jobs.seed = Just 0
                        }

                    _ <- retrieveFineTuningJob (Jobs.id job)

                    _ <- listFineTuningJobs Nothing (Just 20)

                    _ <- listFineTuningCheckpoints (Jobs.id job) Nothing (Just 10)

                    _ <- cancelFineTuning (Jobs.id job)

                    _ <- listFineTuningEvents (Jobs.id job) Nothing (Just 20)

                    _ <- deleteFile (Files.id trainingFile)
                    _ <- deleteFile (Files.id validationFile)

                    return ()

    let batchesTest = do
            HUnit.testCase "Batch operations" do
                run do
                    requestsFile <- uploadFile
                        ( boundary
                        , Files.Request
                            { Files.file =
                                "tasty/data/v1/batches/requests.jsonl"
                            , Files.purpose = Files.Batch
                            }
                        )

                    batch <- createBatch Batches.Request
                        { Batches.input_file_id = Files.id requestsFile
                        , Batches.endpoint = "/v1/chat/completions"
                        , Batches.completion_window = "24h"
                        , Batches.metadata = Nothing
                        }

                    _ <- retrieveBatch (Batches.id batch)

                    _ <- listBatch Nothing (Just 20)

                    _ <- cancelBatch (Batches.id batch)

                    return ()

    let tests =
                speechTests
            <>  [ transcriptionTest
                , translationTest
                , completionsMinimalTest
                , completionsMaximalTest
                , embeddingsTest
                , fineTuningTest
                , batchesTest
                ]

    Tasty.defaultMain (Tasty.testGroup "Tests" tests)
