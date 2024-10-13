module Pages.Home_ exposing (Model, Msg, page)

import Effect exposing (Effect, onLoginSuccess, messageReceiver)
import Html exposing (br, button, div, text, p, input, img, span)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Page exposing (Page)
import Platform.Sub exposing (batch)
import Route exposing (Route)
import Shared
import View exposing (View)
import Markdown


page : Shared.Model -> Route () -> Page Model Msg
page m _ =
    Page.new
        { init = init m
        , subscriptions = subscriptions
        , update = update
        , view = view
        }

type ChatMessage
    = UserMsg String
    | DocMsg String


type alias Model =
    { isLoggedIn : Bool
    , accessToken : Maybe String
    , apiBaseUrl : String
    , apiResponse : Maybe String
    , messages : List ChatMessage
    , newMessage : String
    }


init : Shared.Model -> () -> ( Model, Effect Msg )
init m _ =
    ( { isLoggedIn = False
      , accessToken = Nothing
      , apiBaseUrl = m.apiBaseUrl
      , apiResponse = Nothing
      , messages = []
      , newMessage = ""
      }
    , Effect.none
    )

-- UPDATE


type Msg
    = Login
    | LoginSuccess String
    | CallApi
    | ReceiveApiResponse (Result Http.Error String)
    | Logout
    | UserInputChange String
    | SendMessage
    | ReceiveWSMessage String


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        Login ->
            ( model, Effect.loginWithKeycloak )

        Logout ->
            ( { model | isLoggedIn = False, accessToken = Nothing }
            , Effect.logoutFromKeycloak
            )

        LoginSuccess token ->
            ( { model | isLoggedIn = True, accessToken = Just token }, Effect.none )

        CallApi ->
            case model.accessToken of
                Just token ->
                    let
                        request =
                            Http.request
                                { method = "GET"
                                , headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
                                , url = model.apiBaseUrl ++ "/records"
                                , body = Http.emptyBody
                                , expect = Http.expectString ReceiveApiResponse
                                , timeout = Nothing
                                , tracker = Nothing
                                }
                    in
                    ( model, Effect.sendCmd request )

                Nothing ->
                    ( model, Effect.none )

        ReceiveApiResponse result ->
            case result of
                Ok response ->
                    ( { model | apiResponse = Just response }, Effect.none )

                Err error ->
                    ( { model | apiResponse = Just ("Error: " ++ httpErrorToString error) }, Effect.none )

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


httpErrorToString : Http.Error -> String
httpErrorToString error =
    case error of
        Http.BadUrl url ->
            "Bad URL: " ++ url

        Http.Timeout ->
            "Request timed out"

        Http.NetworkError ->
            "Network error occurred"

        Http.BadStatus statusCode ->
            "Bad response: " ++ String.fromInt statusCode

        Http.BadBody message ->
            "Bad body: " ++ message


-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions _ =
    batch
        [ onLoginSuccess LoginSuccess
        , messageReceiver ReceiveWSMessage
        ]



-- VIEW


view : Model -> View Msg
view model =
    { title = "My Doctor"
    , body =
        [ if model.isLoggedIn then
            button [ onClick Logout ] [ text "Logout" ]

          else
            button [ onClick Login ] [ text "Login" ]
        , br [] []
        , if model.isLoggedIn then
            div []
                [ button [ onClick CallApi ] [ text "Call backend API" ]
                , case model.apiResponse of
                    Just response ->
                        div [] [ text ("API Response: " ++ response) ]

                    Nothing ->
                        text ""
                ]
          else
            div [] []

        , if model.isLoggedIn then 
            chatList model
          else
            div [] []
        ]
    }

chatList : Model -> Html.Html Msg
chatList model =
    div [ class "container mx-auto p-4" ]
        [ div [ class "flex flex-col h-screen bg-white rounded shadow-lg" ]
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
