{-# LANGUAGE BlockArguments    #-}
{-# LANGUAGE NamedFieldPuns    #-}
{-# LANGUAGE OverloadedLists   #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}
{-# LANGUAGE TypeApplications  #-}

{-# OPTIONS_GHC -Wno-orphans #-}

module Main where

import Servant.Client (ClientM)
import OpenAI.Servant.V1 (Methods(..))
import OpenAI.Servant.V1.Audio.Speech (CreateSpeech(..), Voice(..))
import OpenAI.Servant.V1.Audio.Transcriptions (CreateTranscription(..))
import OpenAI.Servant.V1.Audio.Translations (CreateTranslation(..))
import OpenAI.Servant.V1.Batches (Batch(..), CreateBatch(..))
import OpenAI.Servant.V1.Embeddings (CreateEmbeddings(..), EncodingFormat(..))
import OpenAI.Servant.V1.Files (File(..), Order(..), UploadFile(..))
import OpenAI.Servant.V1.Images.Edits (CreateImageEdit(..))
import OpenAI.Servant.V1.Images.Variations (CreateImageVariation(..))

import OpenAI.Servant.V1.Chat.Completions
    ( CallableFunction(..)
    , CalledFunction(..)
    , CreateChatCompletion(..)
    , Message(..)
    , Modality(..)
    , ServiceTier(..)
    , Tool(..)
    , ToolCall(..)
    , ToolChoice(..)
    )
import OpenAI.Servant.V1.FineTuning.Jobs
    (AutoOr(..), CreateFineTuningJob(..), Hyperparameters(..), Job(..))
import OpenAI.Servant.V1.Images.Generations
    (CreateImage(..), Quality(..), Style(..))
import OpenAI.Servant.V1.Uploads
    ( AddUploadPart(..)
    , CompleteUpload(..)
    , CreateUpload(..)
    , Part(..)
    , Upload(..)
    )

import qualified Control.Exception as Exception
import qualified Data.Text as Text
import qualified Network.HTTP.Client as HTTP.Client
import qualified Network.HTTP.Client.TLS as TLS
import qualified OpenAI.Servant.V1 as V1
import qualified OpenAI.Servant.V1.Chat.Completions as Completions
import qualified OpenAI.Servant.V1.Files as Files
import qualified OpenAI.Servant.V1.Images.ResponseFormat as ResponseFormat
import Prelude hiding (id)
import qualified Servant.Client as Client
import qualified System.Environment as Environment
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
                    _ <- createSpeech CreateSpeech
                        { model = "tts-1"
                        , input = "Hello, world!"
                        , voice = Nova
                        , response_format = Just format
                        , speed = Just 1.0
                        }

                    return ()

    let speechTests = do
            format <- [ minBound .. maxBound ]
            return (speechTest format)

    let transcriptionTest =
            HUnit.testCase "Create transcription" do
                run do
                    _ <- createTranscription CreateTranscription
                        { file = "tasty/data/v1/audio/preamble.wav"
                        , model = "whisper-1"
                        , language = Just "en"
                        , prompt = Nothing
                        , temperature = Just 0
                        }

                    return ()

    let translationTest =
            HUnit.testCase "Create translation" do
                run do
                    _ <- createTranslation CreateTranslation
                        { file = "tasty/data/v1/audio/preamble.wav"
                        , model = "whisper-1"
                        , prompt = Nothing
                        , temperature = Just 0
                        }

                    return ()

    let completionsMinimalTest =
            HUnit.testCase "Create chat completion - minimal" do
                run do
                    _ <- createChatCompletion CreateChatCompletion
                        { messages =
                            [ User{ content = "Hello, world!", name = Nothing }
                            ]
                        , model = chatModel
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

                    return ()

    let completionsMaximalTest =
            HUnit.testCase "Create chat completion - maximal" do
                run do
                    _ <- createChatCompletion CreateChatCompletion
                        { messages =
                            [ User
                                { content = "Hello, world!"
                                , name = Just "gabby"
                                }
                            , Assistant
                                { assistant_content = Nothing
                                , refusal = Nothing
                                , name = Just "Ada"
                                , assistant_audio = Nothing
                                , tool_calls = Just
                                    [ ToolCall_Function
                                        { called_id =
                                            "call_bzE95mjMMFqeanfY2sL6Sdir"
                                        , called_function =
                                            CalledFunction
                                              { called_name = "hello"
                                              , called_arguments = "{}"
                                              }
                                        }
                                    ]
                                }
                            , Tool
                                { content = "Hello, world!"
                                , tool_call_id = "call_bzE95mjMMFqeanfY2sL6Sdir"
                                }
                            ]
                        , model = chatModel
                        , store = Just False
                        , metadata = Nothing
                        , frequency_penalty = Just 0
                        , logit_bias = Just mempty
                        , logprobs = Just True
                        , top_logprobs = Just 1
                        , max_completion_tokens = Just 1024
                        , n = Just 1
                        , modalities = Just [ Text ]
                        , prediction = Nothing
                        , audio = Nothing
                        , presence_penalty = Just 0
                        , response_format = Just Completions.ResponseFormat_Text
                        , seed = Just 0
                        , service_tier = Just ServiceTier_Auto
                        , stop = Just [ ">>>" ]
                        , temperature = Just 1
                        , top_p = Just 1
                        , tools = Just
                            [ Tool_Function
                                { callable_function =
                                    CallableFunction
                                      { callable_description =
                                          Just "Use the hello command line tool"
                                      , callable_name = "hello"
                                      , parameters = Nothing
                                      , strict = Just False
                                      }
                                }
                            ]
                        , tool_choice = Just ToolChoiceAuto
                        , parallel_tool_calls = Just True
                        , user = Just user
                        }

                    return ()

    let embeddingsTest = do
            HUnit.testCase "Create embedding" do
                run do
                    _ <- createEmbeddings CreateEmbeddings
                        { input = "Hello, world!"
                        , model = "text-embedding-3-small"
                        , encoding_format = Just Float
                        , dimensions = Just 1024
                        , user = Just user
                        }

                    return ()

    let fineTuningTest = do
            HUnit.testCase "Fine-tuning and File operations - maximal" do
                run do
                    File{ id = trainingId }<- uploadFile UploadFile
                        { file =
                            "tasty/data/v1/fine_tuning/jobs/training_data.jsonl"
                        , purpose = Files.Fine_Tune
                        }

                    File{ id = validationId } <- uploadFile UploadFile
                        { file =
                            "tasty/data/v1/fine_tuning/jobs/validation_data.jsonl"
                        , purpose = Files.Fine_Tune
                        }

                    _ <- retrieveFile trainingId

                    _ <- retrieveFileContent trainingId

                    _ <- listFiles (Just Files.Fine_Tune) (Just 10000) (Just Asc) Nothing

                    Job{ id } <- createFineTuningJob CreateFineTuningJob
                        { model = "gpt-4o-mini-2024-07-18"
                        , training_file = trainingId
                        , hyperparameters = Just
                              Hyperparameters
                                  { batch_size = Just Auto
                                  , learning_rate_multiplier = Just Auto
                                  , n_epochs = Just Auto
                                  }
                        , suffix = Just "haskell-openai"
                        , validation_file = Just validationId
                        , integrations = Just []
                        , seed = Just 0
                        }

                    _ <- retrieveFineTuningJob id

                    _ <- listFineTuningJobs Nothing (Just 20)

                    _ <- listFineTuningCheckpoints id Nothing (Just 10)

                    _ <- cancelFineTuning id

                    _ <- listFineTuningEvents id Nothing (Just 20)

                    _ <- deleteFile trainingId
                    _ <- deleteFile validationId

                    return ()

    let batchesTest = do
            HUnit.testCase "Batch operations" do
                run do
                    File{ id = requestsId } <- uploadFile UploadFile
                        { file = "tasty/data/v1/batches/requests.jsonl"
                        , purpose = Files.Batch
                        }

                    Batch{ id } <- createBatch CreateBatch
                        { input_file_id = requestsId
                        , endpoint = "/v1/chat/completions"
                        , completion_window = "24h"
                        , metadata = Nothing
                        }

                    _ <- retrieveBatch id

                    _ <- listBatch Nothing (Just 20)

                    _ <- cancelBatch id

                    return ()

    let uploadsTest = do
            HUnit.testCase "Upload operations" do
                run do
                    Upload{ id = cancelledId } <- createUpload CreateUpload
                        { filename = "training_data.jsonl"
                        , purpose = Files.Fine_Tune
                        , bytes = 4077
                        , mime_type = "text/jsonl"
                        }

                    _ <- cancelUpload cancelledId

                    Upload{ id } <- createUpload CreateUpload
                        { filename = "training_data.jsonl"
                        , purpose = Files.Fine_Tune
                        , bytes = 4077
                        , mime_type = "text/jsonl"
                        }

                    Part{ part_id = partId0 } <- addUploadPart id AddUploadPart
                        { data_ = "tasty/data/v1/uploads/training_data0.jsonl" }

                    Part{ part_id = partId1 } <- addUploadPart id AddUploadPart
                        { data_ = "tasty/data/v1/uploads/training_data1.jsonl" }

                    _ <- completeUpload id CompleteUpload
                        { part_ids = [ partId0, partId1 ]
                        , md5 = Nothing
                        }

                    return ()

    let createImageMinimalTest = do
            HUnit.testCase "Create image - minimal" do
                run do
                    _ <- createImage CreateImage
                        { prompt = "A baby panda"
                        , model = Nothing
                        , n = Nothing
                        , quality = Nothing
                        , response_format = Nothing
                        , size = Nothing
                        , style = Nothing
                        , user = Nothing
                        }

                    return ()

    let createImageMaximalTest = do
            HUnit.testCase "Create image - maximal" do
                run do
                    _ <- createImage CreateImage
                        { prompt = "A baby panda"
                        , model = Just "dall-e-2"
                        , n = Just 1
                        , quality = Just Standard
                        , response_format = Just ResponseFormat.URL
                        , size = Just "1024x1024"
                        , style = Just Vivid
                        , user = Just user
                        }

                    return ()

    let createImageEditMinimalTest = do
            HUnit.testCase "Create image edit - minimal" do
                run do
                    _ <- createImageEdit CreateImageEdit
                        { image = "tasty/data/v1/images/image.png"
                        , prompt = "The panda should be greener"
                        , mask = Nothing
                        , model = Nothing
                        , n = Nothing
                        , size = Nothing
                        , response_format = Nothing
                        , user = Nothing
                        }

                    return ()

    let createImageEditMaximalTest = do
            HUnit.testCase "Create image edit - maximal" do
                run do
                    _ <- createImageEdit CreateImageEdit
                        { image = "tasty/data/v1/images/image.png"
                        , prompt = "The panda should be greener"
                        , mask = Nothing
                        , model = Just "dall-e-2"
                        , n = Just 1
                        , size = Just "1024x1024"
                        , response_format = Just ResponseFormat.URL
                        , user = Just user
                        }

                    return ()

    let createImageVariationMinimalTest = do
            HUnit.testCase "Create image variation - minimal" do
                run do
                    _ <- createImageVariation CreateImageVariation
                        { image = "tasty/data/v1/images/image.png"
                        , model = Nothing
                        , n = Nothing
                        , response_format = Nothing
                        , size = Nothing
                        , user = Nothing
                        }

                    return ()

    let createImageVariationMaximalTest = do
            HUnit.testCase "Create image variation - maximal" do
                run do
                    _ <- createImageVariation CreateImageVariation
                        { image = "tasty/data/v1/images/image.png"
                        , model = Just "dall-e-2"
                        , n = Just 1
                        , response_format = Just ResponseFormat.URL
                        , size = Just "1024x1024"
                        , user = Just user
                        }

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
                , uploadsTest
                , createImageMinimalTest
                , createImageMaximalTest
                , createImageEditMinimalTest
                , createImageEditMaximalTest
                , createImageVariationMinimalTest
                , createImageVariationMaximalTest
                ]

    Tasty.defaultMain (Tasty.testGroup "Tests" tests)
