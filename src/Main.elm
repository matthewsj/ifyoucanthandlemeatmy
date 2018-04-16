module Main exposing (..)

import Css exposing (..)
import Html
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (..)
import Http
import Json.Decode as Decode


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view >> toUnstyled
        , update = update
        , subscriptions = \_ -> Sub.none
        }



-- MODEL


type alias Model =
    { topic : String
    , ifYouCantHandleMeAtMy : Maybe String
    , youDontDeserveMeAtMy : Maybe String
    }


reloadImagesCmd : String -> Cmd Msg
reloadImagesCmd topic =
    let
        imgCmd =
            getRandomGif topic
    in
    Cmd.batch [ imgCmd, imgCmd ]


refresh : Model -> ( Model, Cmd Msg )
refresh model =
    let
        refreshedModel =
            { model | ifYouCantHandleMeAtMy = Nothing, youDontDeserveMeAtMy = Nothing }
    in
    ( refreshedModel, reloadImagesCmd model.topic )


init : ( Model, Cmd Msg )
init =
    refresh (Model "Beyonce" Nothing Nothing)


type Msg
    = GifLoaded (Result Http.Error String)
    | Reload
    | UpdateTopic String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GifLoaded (Ok url) ->
            ( addImage url model, Cmd.none )

        GifLoaded (Err _) ->
            ( model, Cmd.none )

        Reload ->
            refresh model

        UpdateTopic newTopic ->
            ( { model | topic = newTopic }, Cmd.none )


addImage : String -> Model -> Model
addImage url model =
    case ( model.ifYouCantHandleMeAtMy, model.youDontDeserveMeAtMy ) of
        ( Nothing, _ ) ->
            { model
                | ifYouCantHandleMeAtMy = Just url
            }

        ( Just _, Nothing ) ->
            { model
                | youDontDeserveMeAtMy = Just url
            }

        _ ->
            model


view : Model -> Html Msg
view model =
    div
        [ css
            [ Css.width (pct 70)
            , padding (px 20)
            , marginLeft auto
            , marginRight auto
            , marginTop (px 20)
            , borderRadius (px 10)
            , backgroundColor (hex "#f3f4f0")
            ]
        ]
        [ div
            [ css
                [ displayFlex
                , justifyContent center
                ]
            ]
            [ section "If you can't handle me at my" right model.ifYouCantHandleMeAtMy
            , section "You don't deserve me at my" left model.youDontDeserveMeAtMy
            ]
        , div
            [ css
                [ displayFlex, justifyContent center ]
            ]
            [ div [ css [ displayFlex, flexDirection column ] ]
                [ div
                    [ css
                        [ displayFlex
                        , marginBottom (px 5)
                        , marginTop (px 20)
                        ]
                    ]
                    [ text "Who am I?"
                    , input
                        [ css
                            [ flexGrow (num 1)
                            , flexShrink (num 1)
                            , marginLeft (px 5)
                            ]
                        , type_ "text"
                        , onInput UpdateTopic
                        , value model.topic
                        ]
                        []
                    ]
                , div
                    [ onClick Reload
                    , css
                        [ backgroundColor (hex "#52b3d0")
                        , color (hex "#fbfff9")
                        , borderRadius (px 20)
                        , fontFamily sansSerif
                        , fontWeight bold
                        , paddingLeft (px 20)
                        , paddingRight (px 20)
                        , paddingTop (px 10)
                        , paddingBottom (px 10)
                        , cursor pointer
                        ]
                    ]
                    [ text "In what other cases don't you deserve me?" ]
                ]
            ]
        ]


section : String -> (ExplicitLength IncompatibleUnits -> Css.Style) -> Maybe String -> Html msg
section title floatSide url =
    div
        [ css
            [ padding (px 1)
            , Css.width (pct 50)
            ]
        ]
        [ div
            [ css [ float floatSide, Css.width (pct 70) ] ]
            [ h2
                [ css
                    [ Css.width (px 70) ]
                ]
                [ text title ]
            , case url of
                Just str ->
                    img [ src str, css [ Css.width (pct 100) ] ] []

                Nothing ->
                    div
                        [ css
                            [ Css.width (pct 100)
                            , Css.height (px 220)
                            , displayFlex
                            , alignItems center
                            , justifyContent center
                            ]
                        ]
                        [ i
                            [ classList
                                [ ( "fa", True )
                                , ( "fa-spinner", True )
                                , ( "fa-spin", True )
                                ]
                            ]
                            []
                        ]
            ]
        ]



-- HTTP


getRandomGif : String -> Cmd Msg
getRandomGif topic =
    let
        url =
            "https://api.giphy.com/v1/gifs/random?api_key=zEbsH8tZHgU57yzB3yiB5oEOpJrbO9UB&tag=" ++ topic
    in
    Http.send GifLoaded (Http.get url decodeGifUrl)


decodeGifUrl : Decode.Decoder String
decodeGifUrl =
    Decode.at [ "data", "image_url" ] Decode.string
