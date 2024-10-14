module Pages.Home_ exposing (Model, Msg, page)


import Effect exposing (Effect, onLoginSuccess, messageReceiver)
import Html exposing (h1, button, div, text, p, header, section, footer, span)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)

import Page exposing (Page)
import Platform.Sub exposing (batch)
import Route exposing (Route)
import Shared
import View exposing (View)


page : Shared.Model -> Route () -> Page Model Msg
page m _ =
    Page.new
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }

type ChatMessage
    = UserMsg String
    | DocMsg String


type alias Model =
    {}


init : () -> ( Model, Effect Msg )
init _ =
    ( {}
    , Effect.none
    )

-- UPDATE


type Msg
    = Login


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        Login ->
            ( model, Effect.loginWithKeycloak )


-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


-- VIEW


view : Model -> View Msg
view model =
    { title = "My Doctor"
    , body =
        [ div
            [ style "background" "radial-gradient(circle at top, #1a2a6c, #b21f1f, #fdbb2d)"
            , style "height" "100vh" -- Ensures the background covers the whole viewport
            ]
            [ -- Navigation Bar
            header [ class "flex justify-between items-center p-6" ]
                [ div [ class "text-3xl font-bold" ] [ text "My AI Doctor" ]
                , button [ class "bg-blue-500 hover:bg-blue-700 text-white font-semibold py-2 px-4 rounded-lg shadow-lg", onClick Login ]
                    [ text "Login" ]
                ]

            -- Hero Section
            , section [ class "flex flex-col items-center justify-center h-screen text-center space-y-8" ]
                [ h1 [ class "text-5xl font-extrabold tracking-wide leading-tight" ]
                    [ text "Welcome to "
                    , span [ class "text-transparent bg-clip-text bg-gradient-to-r from-teal-400 to-blue-500" ]
                        [ text "My AI Doctor" ]
                    ]
                , p [ class "text-xl text-gray-300" ]
                    [ text "Your AI-powered healthcare assistant, ready to provide intelligent, compassionate, and personalized medical support." ]
                , button [ class "mt-8 bg-gradient-to-r from-blue-500 to-purple-600 hover:from-blue-600 hover:to-purple-700 text-white font-bold py-4 px-8 rounded-full shadow-2xl transform hover:scale-105 transition duration-300" ]
                    [ text "Get Started" ]
                ]

            -- Footer
            , footer [ class "absolute bottom-0 w-full p-6 text-center text-sm text-gray-200" ]
                [ text "© 2024 Jiwhiz Consulting Inc. All rights reserved." ]
            ]
        ]
    }
