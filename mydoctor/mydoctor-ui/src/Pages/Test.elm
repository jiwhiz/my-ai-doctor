module Pages.Test exposing (Model, Msg, page)

import Auth
import Dict
import Effect exposing (Effect)
import Route exposing (Route)
import Html exposing (header, section, footer, h1, button, div, text, p, input, img, span)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)

import Http
import Page exposing (Page)
import Route.Path
import Shared
import View exposing (View)


page : Auth.User -> Shared.Model -> Route () -> Page Model Msg
page user shared route =
    Page.new
        { init = init user shared
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- INIT


type alias Model =
    { accessToken : String
    , apiBaseUrl : String
    , apiResponse : Maybe String
    }


init : Auth.User -> Shared.Model -> () -> ( Model, Effect Msg )
init user shared _ =
    ( { apiBaseUrl = shared.apiBaseUrl
      , accessToken = user.accessToken
      , apiResponse = Nothing
      }
    , Effect.none
    )



-- UPDATE


type Msg
    = CallApi
    | ReceiveApiResponse (Result Http.Error String)
    | GotoChat
    | Logout


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        CallApi ->
            let
                request =
                    Http.request
                        { method = "GET"
                        , headers = [ Http.header "Authorization" ("Bearer " ++ model.accessToken) ]
                        , url = model.apiBaseUrl ++ "/records"
                        , body = Http.emptyBody
                        , expect = Http.expectString ReceiveApiResponse
                        , timeout = Nothing
                        , tracker = Nothing
                        }
            in
            ( model, Effect.sendCmd request )


        ReceiveApiResponse result ->
            case result of
                Ok response ->
                    ( { model | apiResponse = Just response }, Effect.none )

                Err error ->
                    ( { model | apiResponse = Just ("Error: " ++ httpErrorToString error) }, Effect.none )

        GotoChat ->
            ( model
            , Effect.pushRoute
                { path = Route.Path.Chat
                , query = Dict.empty
                , hash = Nothing
                }
            )

        Logout ->
            ( model
            , Effect.logoutFromKeycloak
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


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Token Exchange Test"
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
                    [ button [ class "bg-blue-500 hover:bg-blue-700 text-white font-semibold py-2 px-4 rounded-lg shadow-lg", onClick GotoChat ]
                        [ text "Chat" ]
                    , button [ class "bg-blue-500 hover:bg-blue-700 text-white font-semibold py-2 px-4 rounded-lg shadow-lg", onClick Logout ]
                        [ text "Logout" ]
                    ]
                ]

            -- Test
            , section [ class "flex-1 flex flex-col items-center justify-center space-y-8" ]
                [ button
                    [ class "bg-blue-500 hover:bg-blue-700 text-white font-bold py-4 px-8 rounded-full shadow-lg"
                    , onClick CallApi
                    ]
                    [ text "Test" ]

                , div [ class "text-white text-lg" ]
                    [ case model.apiResponse of
                        Nothing -> 
                            text ""
                        Just t ->
                            text t
                    ]
                ]

            -- Footer
            , footer [ class "w-full p-6 text-center text-sm text-gray-200" ]
                [ text "© 2024 Jiwhiz Consulting Inc. All rights reserved." ]
            ]
        ]
    }
