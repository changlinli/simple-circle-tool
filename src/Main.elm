module Main exposing (main)

import Browser
import Canvas as C
import Canvas.Settings as CS
import Color -- elm install avh4/elm-color
import Html exposing (Html)
import Html.Attributes as Attributes exposing (style)
import Html.Events as Events

widthOfCanvas = 600

heightOfCanvas = 600

viewCanvas : Model -> Html msg
viewCanvas model =
    C.toHtml (widthOfCanvas, heightOfCanvas)
        [ style "width" (String.fromInt widthOfCanvas ++ "px")
        ]
        (List.map (renderCircle model.scale) model.circles)

processHtmlInput : String -> Msg
processHtmlInput str =
    str
        |> String.toFloat
        |> Maybe.withDefault 0
        |> \x -> x / 50
        |> ChangeScale

view : Model -> Html Msg
view model =
    Html.div
        []
        [ viewCanvas model
        , Html.input
            [ Attributes.type_ "range"
            , Attributes.name "Scaling"
            , Events.onInput processHtmlInput
            ]
            []
        ]

renderCircle : Float -> CircleData -> C.Renderable
renderCircle scale circleData =
    C.shapes
        [ CS.stroke (Color.rgba 0 0 0 1)
        ]
        [ C.circle circleData.location (scale * circleData.startingSize)
        ]

type alias CircleData =
    { location : C.Point
    , startingSize : Float
    }

type alias Model =
    { circles : List CircleData
    , scale : Float
    }

initialModel : Model
initialModel =
    { circles =
        [
            { location = (0, 0)
            , startingSize = 200
            }
        ]
    , scale = 1
    }

type Msg = AddCircle CircleData
    | ChangeScale Float

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = case msg of
    AddCircle circleData -> ({ model | circles = circleData :: model.circles } , Cmd.none)

    ChangeScale float -> ({ model | scale = float } , Cmd.none)



main : Program () Model Msg
main =
    Browser.element
        { init = \() -> ( initialModel, Cmd.none )
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
