module Pages.Chat exposing (Model, Msg, page)

import Auth
import Dict
import Effect exposing (Effect, messageReceiver)
import Route exposing (Route)
import Html exposing (header, section, footer, h1, button, div, text, p, input, img, span)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)

import Page exposing (Page)
import Route.Path
import Shared
import View exposing (View)
import Markdown

page : Auth.User -> Shared.Model -> Route () -> Page Model Msg
page user shared route =
    Page.new
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- INIT


type ChatMessage
    = UserMsg String
    | DocMsg String


type alias Model =
    { messages : List ChatMessage
    , newMessage : String
    }


init :() -> ( Model, Effect Msg )
init _ =
    ( { messages = []
      , newMessage = ""
      }
    , Effect.none
    )



-- UPDATE


type Msg
    = UserInputChange String
    | SendMessage
    | ReceiveWSMessage String
    | GotoTest
    | Logout


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        ReceiveWSMessage message ->
            ( { model | messages = model.messages ++ [ DocMsg message] }
            , Effect.none
            )

        UserInputChange message ->
            ( { model | newMessage = message }
            , Effect.none
            )

        SendMessage ->
            ( { model | messages = model.messages ++ [UserMsg model.newMessage], newMessage = "" }
            , Effect.sendMessageToBackend model.newMessage
            )

        GotoTest ->
            ( model
            , Effect.pushRoute
                { path = Route.Path.Test
                , query = Dict.empty
                , hash = Nothing
                }
            )

        Logout ->
            ( model
            , Effect.logoutFromKeycloak
            )


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    messageReceiver ReceiveWSMessage



-- VIEW


view : Model -> View Msg
view model =
    { title = "My Doctor Chat"
    , body =
        [ div
            [ style "background" "radial-gradient(circle at top, #1a2a6c, #b21f1f, #fdbb2d)"
            , style "height" "100vh"
            , class "flex flex-col"
            ]
            [ -- Navigation Bar
              header [ class "flex justify-between items-center p-6" ]
                [ div [ class "text-3xl font-bold" ] [ text "My AI Doctor" ]
                , div [ class "flex space-x-4 ml-auto" ]
                    [ button [ class "bg-blue-500 hover:bg-blue-700 text-white font-semibold py-2 px-4 rounded-lg shadow-lg", onClick GotoTest ]
                        [ text "Test" ]
                    , button [ class "bg-blue-500 hover:bg-blue-700 text-white font-semibold py-2 px-4 rounded-lg shadow-lg", onClick Logout ]
                        [ text "Logout" ]
                    ]
                ]


            -- Chat Message Box
            , section [ class "flex-1 flex flex-col justify-center items-center w-full" ]
                [ chatContainer model
                ]

            -- Footer
            , footer [ class "w-full p-6 text-center text-sm text-gray-200" ]
                [ text "© 2024 Jiwhiz Consulting Inc. All rights reserved." ]
            ]
        ]
    }


chatContainer : Model -> Html.Html Msg
chatContainer model =
    div [ class "container mx-auto p-4 h-full flex flex-col" ]
        [ div [ class "flex flex-col flex-1 bg-white rounded shadow-lg h-full" ]
            [ -- Chat Header
              div [ class "py-4 px-6 bg-blue-500 text-white font-bold text-xl rounded-t" ]
                [ text "Chat with My AI Doctor" ]
              
              -- Message Area
            , div [ class "flex-1 overflow-y-auto p-4 space-y-4" ]
                (List.map
                    (\m -> 
                        case m of 
                            UserMsg t -> userMessage t
                            DocMsg t -> aiMessage t
                    )
                    model.messages
                )

              -- Input Area
            , div [ class "py-4 px-6 bg-gray-100 rounded-b" ]
                [ div [ class "flex items-center space-x-4" ]
                    [ input [ placeholder "Type a message...", class "w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:border-blue-500", value model.newMessage, onInput UserInputChange ] []
                    , button [ class "bg-blue-500 text-white px-4 py-2 rounded-lg", onClick SendMessage ] [ text "Send" ]
                    ]
                ]
            ]
        ]


aiMessage : String -> Html.Html Msg
aiMessage msgTxt = 
    div [ class "flex items-start" ]
        [ div [ class "flex-shrink-0" ]
            [ img [ src "/doctor-avatar.svg", alt "avatar", class "rounded-full w-10 h-10" ] [] ]
        , div [ class "ml-3" ]
            [ div [ class "bg-gray-100 p-3 rounded-lg" ]
                [ Markdown.toHtml [ class "text-sm text-gray-900" ] msgTxt ]
            , span [ class "text-xs text-gray-500" ] [ text "12:45 PM" ]
            ]
        ]

userMessage : String -> Html.Html Msg 
userMessage msgTxt =
    div [ class "flex justify-end items-start" ]
        [ div [ class "mr-3 text-right" ]
            [ div [ class "bg-blue-500 text-white p-3 rounded-lg" ]
                [ p [ class "text-sm text-gray-900" ] [ text msgTxt ] ]
            , span [ class "text-xs text-gray-500" ] [ text "12:46 PM" ]
            ]
        , div [ class "flex-shrink-0" ]
            [ img [ src "/user-avatar.svg", alt "avatar", class "rounded-full w-10 h-10" ] [] ]
        ]
