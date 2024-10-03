module Pages.Home_ exposing (Model, Msg, page)

import Effect exposing (Effect, onLoginSuccess)
import Html exposing (br, button, div, text, p, input)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Page exposing (Page)
import Platform.Sub exposing (batch)
import Route exposing (Route)
import Shared
import View exposing (View)


page : Shared.Model -> Route () -> Page Model Msg
page m _ =
    Page.new
        { init = init m
        , subscriptions = subscriptions
        , update = update
        , view = view
        }

type alias Model =
    { isLoggedIn : Bool
    , accessToken : Maybe String
    , apiBaseUrl : String
    , apiResponse : Maybe String
    }


init : Shared.Model -> () -> ( Model, Effect Msg )
init m _ =
    ( { isLoggedIn = False
      , accessToken = Nothing
      , apiBaseUrl = m.apiBaseUrl
      , apiResponse = Nothing
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
                                , url = model.apiBaseUrl ++ "/health-records"
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
        ]



-- VIEW


view : Model -> View Msg
view model =
    { title = "My Health"
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

        ]
    }
