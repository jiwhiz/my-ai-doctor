module Shared exposing
    ( Flags, decoder
    , Model, Msg
    , init, update, subscriptions
    )

{-|

@docs Flags, decoder
@docs Model, Msg
@docs init, update, subscriptions

-}

import Dict
import Effect exposing (Effect, onLoginSuccess)
import Json.Decode
import Route exposing (Route)
import Route.Path
import Shared.Model
import Shared.Msg



-- FLAGS


type alias Flags =
    { apiBaseUrl : String
    }


decoder : Json.Decode.Decoder Flags
decoder =
    Json.Decode.map Flags
        (Json.Decode.field "apiBaseUrl" Json.Decode.string)


-- INIT


type alias Model =
    Shared.Model.Model


init : Result Json.Decode.Error Flags -> Route () -> ( Model, Effect Msg )
init flagsResult route =
    ( { user = Nothing
      , apiBaseUrl = 
            case flagsResult of
                Ok flags -> flags.apiBaseUrl

                Err _ -> ""
      }
    , Effect.none
    )


-- UPDATE


type alias Msg =
    Shared.Msg.Msg


update : Route () -> Msg -> Model -> ( Model, Effect Msg )
update route msg model =
    case msg of
        Shared.Msg.LoginSuccess token ->
            ( { model | user = Just { accessToken = token } }
            , Effect.pushRoute
                { path = Route.Path.Chat
                , query = Dict.empty
                , hash = Nothing
                }
            )

        Shared.Msg.Logout ->
            ( { model | user = Nothing }
            , Effect.logoutFromKeycloak
            )



-- SUBSCRIPTIONS


subscriptions : Route () -> Model -> Sub Msg
subscriptions route model =
    onLoginSuccess Shared.Msg.LoginSuccess
