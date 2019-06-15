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
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as JE
import List exposing (range, map, append, filter)
import Debug exposing
  ( log

  )
import Http


main : Program (Model) Model Msg
main =
    Browser.document
        { init = init
        , view = \model -> { title = "Elm • TodoMVC", body = [view model] }
        , update = update
        , subscriptions = \_ -> Sub.none
        }
    --beginnerProgram { model = model, view = view1, update = update1 }

init : Model -> ( Model, Cmd Msg )
init model =
  ( emptyModel
  , Cmd.batch [ getTasksRequest, getUsersRequest ]
  )
--
-- routeInitialCmd : Cmd Msg
-- routeInitialCmd  =
--      getTasksRequest


onChange handler =
    on "change" (Json.map handler targetValue)


type alias Task =
    { taskId : Int
    , title : String
    , description  : String
    , created_by : Int
    , ownerId : Int
    , status : Int
    , due_date : String
    , createdOn : String
    , commentedOn : String
    , isTaskDeleted : Bool
    , isTaskCompleted : Bool
    , showDetails : Bool
    }

type alias User =
  { id : Int
  , name : String
  , email : String
  }

type alias Model =
    { taskCount : Int
    , newTask : Task
    , visibility : String
    , taskList : List Task
    , userList : List User
    , renderView : String
    , user : User
    , currentComment : Comment
    , commentList : List Comment
    }
type alias Comment =
    { commentId : Int
    , taskId :  Int
    , text  :  String
    , createdBy : Int
    }


emptyModel : Model
emptyModel =
    { taskCount = 0
      , newTask = emptyTask
      , visibility = "All"
      , taskList = []
      , userList = []
      , renderView = "Dashboard"
      , user = emptyUser
      , currentComment = defaultComment emptyUser emptyTask
      , commentList =[]
    }
emptyTask : Task
emptyTask =
    { taskId = 1
    , title = ""
    , description = ""
    , created_by = 1
    , ownerId = 1
    , status = 0
    , due_date = "2019-06-10"
    , createdOn = ""
    , commentedOn = ""
    , isTaskDeleted = False
    , isTaskCompleted = False
    , showDetails = False
    }

emptyUser: User
emptyUser =
  { id = 1
  , name = "Mohit"
  , email = "mjindal"
  }



-- UPDATE


type Msg
    = AddTask
    | CreateTask
    | InputTask String
    | InputDescription String
    | CancelTask
    | DeleteIt Int
    | MarkItCompleted Int
    | SwitchVisibility String
    | TaskCreated (Result Http.Error Task)
    | GetTasks
    | TasksFetched  (Result Http.Error (List Task))
    | InputCommentText String
    | CancelComment
    | AddComment  Comment Task
    | CommentsFetched (Result Http.Error (List Comment))
    | CommentCreated  (Result Http.Error Comment)
    | CreateComment Task
    | UsersFetched (Result Http.Error (List User))
    | ShowTaskDetails Task


--type Visibility1 = All | OutStanding | Completed
--port setStorage : Model -> Cmd msg

--    | ClearThis String

-- updateWithStorage : Msg -> Model -> ( Model, Cmd Msg )
-- updateWithStorage msg model =
--     let
--         ( newModel, cmds ) =
--             update msg model
--     in
--         ( newModel
--         , Cmd.batch [ cmds ]
--         )



update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AddTask ->
            --log "Value ==" title
            --(model, createTaskRequest (Task 1 title "Hello Description" 1 1 0 False False) )
            (model, createTaskRequest model.newTask )
        CreateTask ->
          let
            _ = Debug.log "newTask==" model.newTask
          in
            ({model | renderView = "CreateTask", newTask = emptyTask}, Cmd.none )
        InputTask title ->
          let
            task = model.newTask
            newTask = {task | title = title}
          in
            ({model | newTask = newTask}, Cmd.none)
        InputDescription description ->
          let
            task = model.newTask
            newTask = {task | description = description}
          in
            ({model | newTask = newTask}, Cmd.none)
        CancelTask ->
          ({model | renderView = "Dashboard", newTask= emptyTask}, Cmd.none)



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
            },Cmd.none)
        SwitchVisibility visibility ->
            --log (toString visibility)
            ({ model
                | visibility = visibility
            }, Cmd.none)

        TaskCreated (Ok task) ->
            ( {model | taskList = [task] ++ model.taskList, renderView = "Dashboard", newTask = emptyTask}, Cmd.none )

        TaskCreated (Err err) ->
          let
            _ = Debug.log "Error TaskCreated==" err
          in
            ( model, Cmd.none )
        GetTasks ->
            --log "Value ==" title
            (model, getTasksRequest )
        TasksFetched (Ok tasks) ->
            ( {model | taskList = tasks}, Cmd.none )

        TasksFetched (Err err) ->
          let
            _ = Debug.log "Error task fecthed===" err
          in
            ( model, Cmd.none )
        AddComment  comment task->
          (model, createCommentRequest model.user task comment )

        CommentsFetched (Ok comments) ->
           ( {model | commentList = comments} , Cmd.none )

        CommentsFetched (Err err) ->
          let
            _ = Debug.log "Error CommentsFetched fecthed===" err
          in
            ( model, Cmd.none )
        CreateComment task->
         ({model | renderView = "CreateComment", newTask = task}, Cmd.none )

        CommentCreated (Ok comment) ->
            ( {model | renderView ="Dashboard" }, Cmd.none )

        CommentCreated (Err err) ->
          let
            _ = Debug.log "Error CommentCreated fecthed===" err
          in
            ( model, Cmd.none )

        InputCommentText description ->
         let
           comment = model.currentComment
           newComment = {comment | text = description}
         in
           ({model | currentComment = newComment}, Cmd.none)

        CancelComment ->
           ({model | renderView = "Dashboard", currentComment = defaultComment emptyUser emptyTask}, Cmd.none)

        UsersFetched (Ok users) ->
            ( {model | userList = users}, Cmd.none )

        UsersFetched (Err err) ->
          let
            _ = Debug.log "Error users fecthed===" err
          in
            ( model, Cmd.none )

        ShowTaskDetails currentTask ->
          let
            tasks = model.taskList
                      |> List.map (\task -> if task.taskId == currentTask.taskId then {task | showDetails = True} else {task | showDetails = False} )
          in
           ({model | taskList = tasks}, getCommentsRequest currentTask)


keep : String -> List Task -> List Task
keep visibility taskList =
  case visibility of
      "Completed" ->
        List.filter (\task -> task.isTaskCompleted) taskList
      "OutStanding" ->
        List.filter (\task -> not task.isTaskCompleted) taskList
      _ ->
        taskList

renderList lst model =
    ol []
        (List.map
            (\l ->
                li [  ]
                   [ div [class "list-item"]
                           [ div [class "list-header"][div[onClick (ShowTaskDetails l)][label [] [text "Title: "]
                            , label [] [text l.title]
                            , label [] [text "  Description: "]
                            , label [] [text (l.description)]
                            , label [] [text "  Status: "]
                            , label [] [text (getStatus l.status)]
                            , label [] [text "  Commented On: "]
                            , label [] [text l.commentedOn]
                            , button [ onClick (DeleteIt l.taskId)] [text "Delete"]]
                            --, button [ class "button", onClick (AddComment (defaultComment model.user l))][text "Add Comment"]]
                            --, button [ class "button", onClick (CreateComment l) ][text "Add Comment"]
                            --, button [ class "button", onClick (FetchComments  l)][text "Show Comments"]]
                            , if l.showDetails then renderTaskDetails l model else text ""
                            ]
                            -- ,div[class "body"][
                            --   text "body here"
                            -- ]


                           ]


                    ]
            )
            lst
        )

renderTaskComments: List Comment -> Html msg
renderTaskComments comments =
    ol []
        (List.map
            (\comment ->
                li [  ]
                   [ div [class "list-item"]
                           [ div [class "list-header"][div[][textarea [] [text comment.text]]]
                           ]
                    ]
            )
            comments
        )

renderTaskDetails : Task -> Model -> Html Msg
renderTaskDetails task model =
      div []
        [ div []
            [ label [][ text "Owner: "]
            , label [] [text (getUserName model.userList task.ownerId)]
            , label [][ text "  Due Date: "]
            , label [] [text task.due_date]
            , label [][ text "  Created By: "]
            , label [] [text (getUserName model.userList task.created_by)]
            , label [][ text "  Created On: "]
            , label [] [text task.createdOn]
            ]
           --, a [onClick (ShowTaskDetails task)] [text task.title]
           --, div[class "button-collection"][button [ onClick (DeleteIt task.taskId)] [text "Delete"]
           --, button [ class "button", onClick (AddComment (defaultComment model.user l))][text "Add Comment"]]
           , if model.renderView == "CreateComment" then div [ ][ renderCreateCommentView model ] else div [class "button-collection"][button [ class "button", onClick (CreateComment task) ][text "Add Comment"]]
           , renderTaskComments model.commentList  --button [ class "button", onClick (FetchComments task)][text "Show Comments"]
           ]
           -- ,div[class "body"][
           --   text "body here"
           -- ]


getUserName : List User -> Int -> String
getUserName  users id =
  let
    user = users
      |> List.filter( \u -> u.id == id)
      |> List.head
      |> Maybe.withDefault emptyUser
  in
    user.name

-- VIEW


view : Model -> Html Msg
view model =
  let
    openSidePanel=
      case model.renderView of
        "CreateTask" ->
          True
        "CreateComment" ->
          True
        _ ->
          False
  in
  div[][
    div[class "header"][
    h1 [class "headerStyle"] [ text "Dashboard" ]
    , button [ onClick CreateTask ] [text "Create Task"]
    ]
    ,div [class "panel"]
      [

      renderDashboard model
      , if model.renderView == "CreateTask" then div [ classList [( "mini-panel", True), ("show", openSidePanel),  ("hide", not openSidePanel)] ][ renderCreateTaskView model ] else text ""

      ]
  ]


renderDashboard: Model -> Html Msg
renderDashboard model =
    div [class "main-panel"]
        [
        h2 [class "headerStyle"] [ text ("My Tasks" ++ model.renderView) ]
        , div [class "filter"] [  radio "All" (SwitchVisibility "All") (if model.visibility == "All" then True else False)
                    , radio "Completed" (SwitchVisibility "Completed") (if model.visibility == "Completed" then True else False)
                    , radio "Outstanding" (SwitchVisibility "OutStanding") (if model.visibility == "OutStanding" then True else False)

                  ]

        , renderList (keep model.visibility model.taskList) model
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
renderCreateTaskView: Model -> Html Msg
renderCreateTaskView model =
  div []
      [ h1 [] [ text "Create New Task" ]
      , div[class "fieldset"][label [] [text "Want to track a task? Add here!"]
      , input [  placeholder "Want to track a task? Add here!"
              , onInput InputTask
              , value model.newTask.title
              ]
              []]
      , div[class "fieldset"][label [] [text "Description"]
      , textarea [ onInput InputDescription , value model.newTask.description
              ]
              []
              ]
      ,div[class "button-collection"][ button [ class "primary", onClick AddTask ] [text "Create"]
      , button [ onClick CancelTask ] [text "Cancel"]]
      ]

createTaskRequest : Task -> Cmd Msg
createTaskRequest task =
    Http.post
        { url = "http://172.15.3.209:9999/task-bucket-api/tasks"
        , body = Http.jsonBody (newTaskEncoder task)
        , expect = Http.expectJson TaskCreated taskDecoder
        --, timeout = Nothing
        --, withCredentials = False
        }
getTasksRequest : Cmd Msg
getTasksRequest =
  Http.get
      { url = "http://172.15.3.209:9999/task-bucket-api/tasks"
      , expect = Http.expectJson TasksFetched taskListDecoder
      --, timeout = Nothing
      --, withCredentials = False
      }


newTaskEncoder : Task -> JE.Value
newTaskEncoder task =
  let
    _ = log "task===" task
  in
    JE.object
        [ ( "title", JE.string task.title )
        , ( "description", JE.string task.description )
        , ( "created_by", JE.int task.created_by )
        , ( "owner", JE.int task.ownerId )
        , ( "status", JE.int task.status )
        , ( "due_date", JE.string task.due_date )
        ]

taskDecoder : Json.Decoder Task
taskDecoder =
    Json.succeed Task
        |> required "id" Json.int
        |> required "title" Json.string
        |> optional "description" Json.string ""
        |> optional "created_by" Json.int 0
        |> optional "owner" Json.int 0
        |> optional "status" Json.int 0
        |> optional "due_date" Json.string "2019-06-10"
        |> optional "createtime" Json.string ""
        |> optional "last_commented_on" Json.string ""
        |> optional "isTaskDeleted" Json.bool False
        |> optional "isTaskCompleted" Json.bool False
        |> optional "showDetails" Json.bool False

taskListDecoder : Json.Decoder (List Task)
taskListDecoder = Json.list taskDecoder

---- Code for Comment Sections ---


defaultComment : User -> Task ->  Comment
defaultComment  user task =
  Comment 0 task.taskId  task.title user.id

createCommentRequest : User -> Task -> Comment -> Cmd Msg
createCommentRequest user task comment =
   Http.post
       { url = "http://172.15.3.209:9999/task-bucket-api/tasks/"++ String.fromInt(task.taskId) ++"/comments"
       , body = Http.jsonBody (createCommentEncoder user task comment)
       , expect = Http.expectJson CommentCreated commentDecoder
       }

createCommentEncoder : User -> Task -> Comment -> JE.Value
createCommentEncoder user task comment=
   JE.object
       [ ( "task_id", JE.int task.taskId )
       , ( "text", JE.string comment.text )
       , ( "created_by", JE.int user.id )
       ]

commentDecoder : Json.Decoder Comment
commentDecoder =
   Json.succeed Comment
       |> required "commentId" Json.int
       |> required "taskId" Json.int
       |> optional "text" Json.string ""
       |> optional "createdBy" Json.int 1


getCommentsRequest : Task -> Cmd Msg
getCommentsRequest task =
 Http.get
     {
     url = "http://172.15.3.209:9999/task-bucket-api/tasks/" ++ String.fromInt(task.taskId) ++"/comments"
     , expect = Http.expectJson CommentsFetched commentListDecoder
     }

commentListDecoder : Json.Decoder (List Comment)
commentListDecoder = Json.list commentDecoder

renderCreateCommentView: Model -> Html Msg
renderCreateCommentView model =
 div []
     [ h1 [] [ text "Create Comments" ]
     , textarea [ onInput InputCommentText
             ]
             []
     , button [ onClick (AddComment model.currentComment model.newTask)] [text "Create"]
     , button [ onClick CancelComment ] [text "Cancel"]
     ]

userDecoder : Json.Decoder User
userDecoder =
   Json.succeed User
       |> required "id" Json.int
       |> required "name" Json.string
       |> optional "email" Json.string ""


getUsersRequest : Cmd Msg
getUsersRequest =
 Http.get
     { url = "http://172.15.3.209:9999/task-bucket-api/users"
     , expect = Http.expectJson UsersFetched userListDecoder
     }

userListDecoder : Json.Decoder (List User)
userListDecoder = Json.list userDecoder

getStatus : Int -> String
getStatus status =
  case status of
    0 -> "New"
    1 -> "In Progress"
    2 -> "Completed"
    _ -> "Cancelled"
