port module Main exposing (..)

{-| TodoMVC implemented in Elm, using plain HTML and CSS for rendering.

This application is broken up into three key parts:

  1. Model  - a full definition of the application's state
  2. Update - a way to step the application state forward
  3. View   - a way to visualize our application state with HTML

This clean division of concerns is a core part of Elm. You can read more about
this in <http://guide.elm-lang.org/architecture/index.html>
-}

import Browser
import Browser.Dom as Dom
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
--import Html.Keyed as Keyed
--import Html.Lazy exposing (lazy, lazy2)
import Json.Decode as Json
--import Task

--import Html exposing (Html, Attribute, beginnerProgram, label, text, div, span, input, button, br, h1, ol, li, fieldset, img)

--import Html.Events exposing (on, targetValue, onClick, onInput)
import Json.Decode as Json
import List exposing (range, map, append, filter)
import Debug exposing
  ( log

  )
import Http


main : Program (Maybe Model) Model Msg
main =
    Browser.document
        { init = init
        , view = \model -> { title = "Elm • TodoMVC", body = [view model] }
        , update = updateWithStorage
        , subscriptions = \_ -> Sub.none
        }
    --beginnerProgram { model = model, view = view1, update = update1 }

init : Maybe Model -> ( Model, Cmd Msg )
init maybeModel =
  ( Maybe.withDefault emptyModel maybeModel
  , Cmd.none
  )

onChange handler =
    on "change" (Json.map handler targetValue)


type alias Task =
    { taskId : Int
    , taskText : String
    , isTaskDeleted : Bool
    , isTaskCompleted : Bool
    }


type alias Model =
    { taskCount : Int
      , todo : String
      , visibility : String
      , taskList : List Task
    }

emptyModel : Model
emptyModel =
    { taskCount = 0
      , todo = ""
      , visibility = "All"
      , taskList = []
    }



-- UPDATE


type Msg
    = AddTask String
    | ClearList
    | DeleteIt Int
    | MarkItCompleted Int
    | SwitchVisibility String
    | GotText (Result Http.Error String)

--type Visibility1 = All | OutStanding | Completed
port setStorage : Model -> Cmd msg

--    | ClearThis String

updateWithStorage : Msg -> Model -> ( Model, Cmd Msg )
updateWithStorage msg model =
    let
        ( newModel, cmds ) =
            update msg model
    in
        ( newModel
        , Cmd.batch [ setStorage newModel, cmds ]
        )



update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AddTask taskText ->
            --log "Value ==" taskText
            ({ model
                | taskCount = model.taskCount + 1
                , todo = ""
                , taskList = List.append model.taskList [ Task (model.taskCount + 1) taskText False False ]
            }, Cmd.none)

        ClearList ->
            ({ model
                | taskCount = 0
                , todo = ""
                , visibility = "All"
                , taskList = []
            }, Cmd.none)

        DeleteIt id ->
            --log (toString id)
            ({ model
                | taskCount = model.taskCount
                , taskList = List.filter (\task -> task.taskId /= id) model.taskList
            }, Cmd.none)
        MarkItCompleted id ->
          -- let
          --   log "Hello G==" id
          -- in
            ({ model
                | taskList = List.map (\task -> if task.taskId == id then
                                                  {task | isTaskCompleted = not task.isTaskCompleted}
                                                else task
                                      ) model.taskList
            }, Http.get
            { url = "http://172.15.3.209:9999/task-bucket-api/hello"--"http://localhost:9999/task-bucket-api/hello1"
            , expect = Http.expectString GotText
            })
        SwitchVisibility visibility ->
            --log (toString visibility)
            ({ model
                | visibility = visibility
            }, Cmd.none)
        GotText result ->
          case result of
            Ok fullText ->
              ({model | todo = fullText} , Cmd.none)
            Err _ ->
              (model, Cmd.none)


keep : String -> List Task -> List Task
keep visibility taskList =
  case visibility of
      "Completed" ->
        List.filter (\task -> task.isTaskCompleted) taskList
      "OutStanding" ->
        List.filter (\task -> not task.isTaskCompleted) taskList
      _ ->
        taskList

{- ClearThis y ->
   {model
     | taskList = spliceList model.taskList y}
-}
--renderList : List Task -> Html Msg


renderList lst =
    ol []
        (List.map
            (\l ->
                li [  ]
                   [ label []
                           [ input [ type_ "checkbox"
                                   , onClick (MarkItCompleted l.taskId)
                                   , checked l.isTaskCompleted
                                   ]
                                   []
                            , div [] [text l.taskText]
                           ]
                    , img [src "http://www.freeiconspng.com/uploads/remove-icon-png-26.png"
                          , alt "Delete/Remove"
                          --, deleteStyle
                          , onClick (DeleteIt l.taskId)
                          ]
                          []
                    ]
            )
            lst
        )

-- VIEW


view : Model -> Html Msg
view content =
    div []
        [ h1 [] [ text "ToDo List" ]
        , span [] [ fieldset []
                            [ radio "All" (SwitchVisibility "All") (if content.visibility == "All" then True else False)
                            , radio "Completed" (SwitchVisibility "Completed") (if content.visibility == "Completed" then True else False)
                            , radio "Outstanding" (SwitchVisibility "OutStanding") (if content.visibility == "OutStanding" then True else False)
                            ]
                    -- , button [ --buttonStyle
                    --           onClick ClearList
                    --          , src "https://cdn.shopify.com/s/files/1/0556/7973/t/30/assets/free-returns-i.png?3729309556114054824"
                    --          ]
                    --          [ text "Reset Task List" ]
                  ]
        , input [  placeholder "Want to track a task? Add here!"
                , onChange AddTask
                , value content.todo
                ]
                []
        --, div [ myStyle ] [ text "Total no. of tasks : ", text (toString content.taskCount) ]
        , renderList (keep content.visibility content.taskList)
        ]


radio : String -> msg -> Bool -> Html msg
radio value msg isChecked=
  label
    [ --style [("padding", "0px 10px 0px 10px"), ("margin", "0px 3px 0px 3px"), ("cursor", "pointer"),("border","0px solid")]
    ]
    [ input [ type_ "radio"
              , style "cursor" "pointer"
              , checked isChecked
              , name "visibilty-check"
              , onClick msg
            ] []
    , text value
    ]

-- headerStyle =
--     style
--         [ ( "width", "100%" )
--         , ( "height", "40px" )
--         , ( "padding", "10px 0" )
--         , ( "font-size", "2em" )
--         , ( "text-align", "center" )
--         ]
--
--
-- myStyle =
--     style
--         [ ( "width", "100%" )
--         , ( "height", "40px" )
--         , ( "padding", "10px 0" )
--         , ( "font-size", "2em" )
--         , ( "text-align", "center" )
--         ]
--
--
-- buttonStyle =
--     style
--         [ ( "width", "30px" )
--         , ( "height", "30px" )
-- --        , ( "padding", "3px 3px 3px 3px" )
-- --        , ( "margin", "3px 3px 30px 10px" )
--         , ( "text-align", "center" )
--         , ( "cursor", "pointer")
--         , ( "display", "inline" )
--         ]
--
-- deleteStyle =
--     style
--         [("cursor", "pointer")
--         , ("position", "absolute")
--         , ("right","21px")
--         , ("height","21px")
--         , ("margin-right","10px")
--         ]
-- taskLiStyle =
--     style
--         [ ( "padding", "10px 20px 10px 20px" )
--         , ("position", "relative")
--         , ("width","600px")
--         , ("border","0px solid")
--         ]
-- taskTextStyle =
--     style
--         [ ("top", "7px")
--         , ("left","45px")
--         , ("display","block")
--         , ("overflow", "auto")
--         , ("font-size","1.2em")
--         , ("width","500px")
--         , ("height","25px")
--         , ("position","absolute")
--         , ("border","0px solid")
--         ]
