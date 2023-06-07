module Main exposing (main)

import Browser
import Canvas as C
import Collage exposing (circle, defaultLineStyle, outlined, rectangle)
import Collage.Layout as Layout exposing (at)
import Collage.Render exposing (svg, svgExplicit)
import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events as Events
import Html.Events.Extra.Mouse as Mouse
import Svg
import Svg.Attributes as Svg

widthOfCanvas = 600

heightOfCanvas = 600

viewCircleData : Float -> CircleData -> Collage.Collage msg -> Collage.Collage msg
viewCircleData scale circleData =
    circle (scale * circleData.startingSize)
        |> outlined defaultLineStyle
        |> at (\_ -> circleData.location)

customRenderCollage : List (Html.Attribute msg) -> Collage.Collage msg -> Html msg
customRenderCollage attributes collage =
  Html.div
    []
    [ svgExplicit
        (
            [ Svg.width (Layout.width collage |> String.fromFloat)
            , Svg.height (Layout.height collage |> String.fromFloat)
            , Svg.version "1.1"
            ] ++ attributes
        )
        (Layout.align Layout.topLeft collage)
    ]

viewCanvas : Model -> Html Msg
viewCanvas model =
    let
        circles : List (Collage.Collage Msg -> Collage.Collage Msg)
        circles =
            model.circles |> List.map (viewCircleData model.scale)

        rect : Collage.Collage Msg
        rect =
            rectangle widthOfCanvas heightOfCanvas
                |> outlined defaultLineStyle

        apply = (<|)

        collage : Collage.Collage Msg
        collage =
            List.foldl apply rect circles
    in
    collage
        |> customRenderCollage [ Mouse.onMove (.offsetPos >> ChangeMousePosition) ]

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
            , Attributes.max "200"
            , Events.onInput processHtmlInput
            ]
            []
        , Html.input
            [ Attributes.type_ "number"
            , Attributes.name "New Circle Dimensions"
            , Events.onInput (\str -> ChangeNewCircleDefaultSize (String.toFloat str |> Maybe.withDefault 0))
            ]
            []
        , Html.input
            [ Attributes.type_ "text"
            , Attributes.name "New Circle Dimensions"
            , Events.onInput ChangeCircleTextInput
            ]
            []
        , Html.button
            [ Events.onClick SubmitNewCircle
            ]
            [ Html.text "Submit new circle" ]
        , Html.div
            []
            [ Html.text ("Current mouse position: " ++ (formatPosition model.currentMousePosition)) ]
        ]

formatPosition : (Float, Float) -> String
formatPosition (x, y) =
    "(" ++ (x |> String.fromFloat) ++ ", " ++ (y |> String.fromFloat) ++ ")"

type alias CircleData =
    { location : C.Point
    , startingSize : Float
    }

type alias Model =
    { circles : List CircleData
    , scale : Float
    , currentCircleTextInput : String
    , currentCircleDefaultSize : Float
    -- Use same coordinate system as Collage
    , currentMousePosition : (Float, Float)
    }

initialModel : Model
initialModel =
    { circles =
        []
    , scale = 1
    , currentCircleTextInput = ""
    , currentCircleDefaultSize = 100
    , currentMousePosition = (0, 0)
    }

type Msg = ChangeCircleTextInput String
    | ChangeNewCircleDefaultSize Float
    | SubmitNewCircle
    | ChangeScale Float
    | ChangeMousePosition (Float, Float)


parseCircleData : Float -> String -> Maybe CircleData
parseCircleData startingSize str =
    String.split "," str
        |> List.map String.toFloat
        |> List.concatMap
            (\x -> case x of
                Just float -> [ float ]
                Nothing -> []
            )
        |> \xs -> Maybe.map2 (\x y -> { location = (x, y), startingSize = startingSize }) (List.head xs) (List.head xs)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = case msg of
    ChangeScale float -> ({ model | scale = float } , Cmd.none)

    ChangeCircleTextInput string -> ({ model | currentCircleTextInput = string } , Cmd.none)


    SubmitNewCircle ->
        let
            newCircleMaybe = parseCircleData model.currentCircleDefaultSize model.currentCircleTextInput
        in
        case newCircleMaybe of
            Just newCircle ->
                ({ model | currentCircleTextInput = "", currentCircleDefaultSize = 100, circles = newCircle :: model.circles  } , Cmd.none)

            Nothing -> (model, Cmd.none)

    ChangeNewCircleDefaultSize float -> ({ model | currentCircleDefaultSize = float }, Cmd.none)

    ChangeMousePosition (x, y) -> ({ model | currentMousePosition = (x - widthOfCanvas / 2, y - heightOfCanvas / 2) }, Cmd.none)







main : Program () Model Msg
main =
    Browser.element
        { init = \() -> ( initialModel, Cmd.none )
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
