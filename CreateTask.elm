import Html exposing (Html, Attribute, beginnerProgram, label, text, div, span, input, button, br, h1, ol, li, fieldset, img)
import Html.Attributes exposing (..)
import Html.Events exposing (on, targetValue, onClick, onInput)
import Json.Decode as Json
import List exposing (range, map, append, filter)
import Debug exposing
  ( log
  , crash
  )
--JMD

main =
    beginnerProgram { model = model, view = view1, update = update1 }


onChange handler =
    on "change" (Json.map handler targetValue)


type alias Task =
    { taskId : Int
    , taskText : String
    , isTaskDeleted : Bool
    , isTaskCompleted : Bool
    }


type alias Model1 =
    { taskCount : Int
      , todo : String
      , visibility : Visibility
      , taskList : List Task
    }


model : Model1
model =
    Model1 0 "" All []



-- UPDATE


type Msg
    = AddTask String
    | ClearList
    | DeleteIt Int
    | MarkItCompleted Int
    | SwitchVisibility Visibility

type Visibility = All | OutStanding | Completed


--    | ClearThis String


update1 msg model =
    case msg of
        AddTask taskText ->
            log taskText
            { model
                | taskCount = model.taskCount + 1
                , todo = ""
                , taskList = List.append model.taskList [ Task (model.taskCount + 1) taskText False False ]
            }

        ClearList ->
            Model1 0 "" All []

        DeleteIt id ->
            log (toString id)
            { model
                | taskCount = model.taskCount
                , taskList = List.filter (\task -> task.taskId /= id) model.taskList
            }
        MarkItCompleted id ->
            { model
                | taskList = List.map (\task -> if task.taskId == id then
                                                  {task | isTaskCompleted = not task.isTaskCompleted}
                                                else task
                                      ) model.taskList
            }
        SwitchVisibility visibility ->
            log (toString visibility)
            { model
                | visibility = visibility
            }

keep : Visibility -> List Task -> List Task
keep visibility taskList =
  case visibility of
      Completed ->
        List.filter (\task -> task.isTaskCompleted) taskList
      OutStanding ->
        List.filter (\task -> not task.isTaskCompleted) taskList
      All ->
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
                li [ taskLiStyle ]
                   [ label []
                           [ input [ type_ "checkbox"
                                   , onClick (MarkItCompleted l.taskId)
                                   , checked l.isTaskCompleted
                                   ]
                                   []
                            , div [taskTextStyle] [text l.taskText]
                           ]
                    , img [src "http://www.freeiconspng.com/uploads/remove-icon-png-26.png"
                          , alt "Delete"
                          , deleteStyle
                          , onClick (DeleteIt l.taskId)
                          ]
                          []
                    ]
            )
            lst
        )

-- VIEW


view1 : Model1 -> Html Msg
view1 content =
    div []
        [ h1 [ style [ ( "text-align", "center" ) ] ] [ text "ToDo List" ]
        , span [] [ fieldset [style[("border","0px solid"), ("display", "inline")]]
                            [ radio "All" (SwitchVisibility All) (if content.visibility == All then True else False)
                            , radio "Completed" (SwitchVisibility Completed) (if content.visibility == Completed then True else False)
                            , radio "Outstanding" (SwitchVisibility OutStanding) (if content.visibility == OutStanding then True else False)
                            ]
                    , img [ buttonStyle
                             , onClick ClearList
                             , src "https://cdn.shopify.com/s/files/1/0556/7973/t/30/assets/free-returns-i.png?3729309556114054824"
                             ]
                             [ text "Reset Task List" ]
                  ]
        , input [ myStyle, placeholder "Want to track a task? Add here!"
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
    [ style [("padding", "0px 10px 0px 10px"), ("margin", "0px 3px 0px 3px"), ("cursor", "pointer"),("border","0px solid")]
    ]
    [ input [ type_ "radio"
              , style [("cursor", "pointer")]
              , checked isChecked
              , name "visibilty-check"
              , onClick msg
            ] []
    , text value
    ]

headerStyle =
    style
        [ ( "width", "100%" )
        , ( "height", "40px" )
        , ( "padding", "10px 0" )
        , ( "font-size", "2em" )
        , ( "text-align", "center" )
        ]


myStyle =
    style
        [ ( "width", "100%" )
        , ( "height", "40px" )
        , ( "padding", "10px 0" )
        , ( "font-size", "2em" )
        , ( "text-align", "center" )
        ]


buttonStyle =
    style
        [ ( "width", "30px" )
        , ( "height", "30px" )
--        , ( "padding", "3px 3px 3px 3px" )
--        , ( "margin", "3px 3px 30px 10px" )
        , ( "text-align", "center" )
        , ( "cursor", "pointer")
        , ( "display", "inline" )
        ]

deleteStyle =
    style
        [("cursor", "pointer")
        , ("position", "absolute")
        , ("right","21px")
        , ("height","21px")
        , ("margin-right","10px")
        ]
taskLiStyle =
    style
        [ ( "padding", "10px 20px 10px 20px" )
        , ("position", "relative")
        , ("width","600px")
        , ("border","0px solid")
        ]
taskTextStyle =
    style
        [ ("top", "7px")
        , ("left","45px")
        , ("display","block")
        , ("overflow", "auto")
        , ("font-size","1.2em")
        , ("width","500px")
        , ("height","25px")
        , ("position","absolute")
        , ("border","0px solid")
        ]        
