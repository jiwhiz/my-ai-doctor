module Pages.Home_ exposing (Model, Msg, page)

import Effect exposing (Effect, onLoginSuccess, messageReceiver)
import Html exposing (br, button, div, text, p, input)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Markdown.Option exposing (..)
import Markdown.Render exposing (MarkdownMsg(..), MarkdownOutput(..))
import Page exposing (Page)
import Platform.Sub exposing (batch)
import Route exposing (Route)
import Shared
import View exposing (View)
import Markdown.Render


page : Shared.Model -> Route () -> Page Model Msg
page _ _ =
    Page.new
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }

type alias Model =
    { isLoggedIn : Bool
    , accessToken : Maybe String
    , apiResponse : Maybe String
    , messages : List String
    , newMessage : String
    }


init : () -> ( Model, Effect Msg )
init _ =
    ( { isLoggedIn = False
      , accessToken = Nothing
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
    | MarkdownMsg Markdown.Render.MarkdownMsg


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
                                , url = "http://api.mydoctor:8081/api/records"
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
            ( { model | messages = model.messages ++ [message] }
            , Effect.none
            )

        UserInputChange message ->
            ( { model | newMessage = message }
            , Effect.none
            )

        SendMessage ->
            ( { model | messages = model.messages ++ [model.newMessage], newMessage = "" }
            , Effect.sendMessageToBackend model.newMessage
            )

        MarkdownMsg _ ->
            ( model, Effect.none )

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
        , button [ onClick CallApi ] [ text "Call backend API" ]
        , case model.apiResponse of
            Just response ->
                div [] [ text ("API Response: " ++ response) ]

            Nothing ->
                text ""

        , if model.isLoggedIn then 
            div [class "chat-container"]
                [ div [ class "chat-box"]
                    [ div [ class "card" ]
                        [ div [ class "card-header" ] [ text "Messages" ]
                        , div [ class "card-body" ] 
                            [ div [ class "messages"]
                                [ div [] (List.map (\m -> p [] [ Markdown.Render.toHtml Standard m |> Html.map MarkdownMsg ]) model.messages)] 
                            , br [] []
                            ]
                        , div [ class "card-footer" ]
                            [ input [ placeholder "Your message", value model.newMessage, onInput UserInputChange ] []
                            , button [ onClick SendMessage ] [ text "Send" ]
                            ]
                        ]
                    ]
                ]
          else
            div [] []
        ]
    }
