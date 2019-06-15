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
  ( Maybe.withDefault emptyModel (Just emptyModel)
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

type alias ID =
    { id : Int
    }
type alias Message =
    { message : String
    }


type alias Model =
    { taskCount : Int
    , newTask : Task
    , visibility : String
    , taskList : List Task
    , filteredTaskList : List Task
    , userList : List User
    , renderView : String
    , user : User
    , currentComment : Comment
    , commentList : List Comment
    , filterValues : FilterValues
    }

type alias Comment =
    { commentId : Int
    , taskId :  Int
    , text  :  String
    , createdBy : Int
    }

type alias FilterValues =
    { due_date : String
    , create_date : String
    , createdBy : Int
    , titleSearchText : String
    , showCreatorDropdown : Bool
    , selectedCreatorList : List User
    , showOwnerDropdown : Bool
    , selectedOwnerList : List User
    }

emptyModel : Model
emptyModel =
    { taskCount = 0
      , newTask = emptyTask
      , visibility = "All"
      , taskList = []
      , filteredTaskList = []
      , userList = []
      , renderView = "Dashboard"
      , user = emptyUser
      , currentComment = defaultComment emptyUser emptyTask
      , commentList = []
      , filterValues = { due_date = "2019-06-15"
                        , create_date = "2019-6-15"
                        , createdBy = 1
                        , titleSearchText = ""
                        , showCreatorDropdown = False
                        , selectedCreatorList = []
                        , showOwnerDropdown = False
                        , selectedOwnerList = []
                      }
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
    | ShowFilterPanel
    | InputTask String
    | InputDescription String
    | CancelTask
    | DeleteTask Task
    | MarkItCompleted Int
    | SwitchVisibility String
    | TaskCreated (Result Http.Error Task)
    | TaskDeleted (Result Http.Error Message)
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
    | ApplyFilter
    | CancelFilter
    | InputFilterDueDate String
    | InputFilterCreateDate String
    | InputFilterTitleSearchText String
    | ToggleCreatorDropdown
    | FilterCreatorRecord User
    | ToggleOwnerDropdown
    | FilterOwnerRecord User
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
        AddTask ->
            --log "Value ==" title
            --(model, createTaskRequest (Task 1 title "Hello Description" 1 1 0 False False) )
            (model, createTaskRequest model.newTask )
        CreateTask ->
          let
            _ = Debug.log "newTask==" model.newTask
          in
            ({model | renderView = "CreateTask", newTask = emptyTask}, Cmd.none )
        ShowFilterPanel ->
          let
            _ = Debug.log "showFilterPanel==" ""
          in
            ({model | renderView = "FilterTasks"}, Cmd.none )
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

        DeleteTask taskToBeDeleted ->
          let
            taskList = List.filter (\task -> task.taskId /= taskToBeDeleted.taskId) model.taskList
          in
            --log (toString id)
            ({ model
                | taskCount = model.taskCount
                , taskList = taskList
                , filteredTaskList = taskList
            }, deleteTaskRequest taskToBeDeleted)
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
        TaskDeleted (Ok message) ->
            ( model, Cmd.none )

        TaskDeleted (Err err) ->
          let
            _ = Debug.log "Error TaskDeleted==" err
          in
            ( model, Cmd.none )
        GetTasks ->
            --log "Value ==" title
            (model, getTasksRequest )
        TasksFetched (Ok tasks) ->
            ( {model | taskList = tasks, filteredTaskList = tasks}, Cmd.none )

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
            ( {model | renderView ="Dashboard" }, getCommentsRequest comment.taskId )

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
        InputFilterDueDate due_date ->
         let
           _ = Debug.log "InputFilterDueDate ===" due_date
           filterValues = model.filterValues
           filterValuesUpdated = {filterValues | due_date = due_date}
         in
           ({model | filterValues = filterValuesUpdated}, Cmd.none)
        InputFilterCreateDate create_date ->
         let
           _ = Debug.log "InputFilterCreateDate ===" create_date
           filterValues = model.filterValues
           filterValuesUpdated = {filterValues | create_date = create_date}
         in
           ({model | filterValues = filterValuesUpdated}, Cmd.none)
        InputFilterTitleSearchText searchText ->
           let
             _ = Debug.log "InputFilterTitleSearchText ===" searchText
             filterValues = model.filterValues
             filterValuesUpdated = {filterValues | titleSearchText = searchText}
           in
           ({model | filterValues = filterValuesUpdated}, Cmd.none)
        ApplyFilter ->
          let
            _ = Debug.log "ApplyFilter ==="
            tempFilteredTaskList =
              if model.filterValues.due_date == "" then
                model.taskList
              else
                List.filter (\task -> task.due_date == model.filterValues.due_date) model.taskList

            temp0FilteredTaskList =
              if model.filterValues.create_date == "" then
                tempFilteredTaskList
              else
                List.filter (\task -> task.createdOn == model.filterValues.create_date) tempFilteredTaskList

            temp1FilteredTaskList =
              if model.filterValues.titleSearchText == "" then
                tempFilteredTaskList
              else
                List.filter (\task -> String.contains (String.toLower model.filterValues.titleSearchText) (String.toLower task.title) ) temp0FilteredTaskList

            temp2FilteredTaskList =
              let
                selectedCreatorList = model.filterValues.selectedCreatorList
                selectedCreatorIdList = List.map (\selectedCreator -> selectedCreator.id) selectedCreatorList
              in
                if List.isEmpty selectedCreatorIdList
                  then
                    temp1FilteredTaskList
                  else
                    List.filter (\task -> List.member task.created_by selectedCreatorIdList) temp1FilteredTaskList

            temp3FilteredTaskList =
              let
                selectedOwnerList = model.filterValues.selectedOwnerList
                selectedOwnerIdList = List.map (\selectedOwner -> selectedOwner.id) selectedOwnerList
              in
                if List.isEmpty selectedOwnerIdList
                  then
                    temp2FilteredTaskList
                  else
                    List.filter (\task -> List.member task.created_by selectedOwnerIdList) temp2FilteredTaskList


          in
            ({ model
                | filteredTaskList = temp3FilteredTaskList
            }, Cmd.none)
        CancelFilter ->
           ({model | filteredTaskList = model.taskList, renderView = "Dashboard"}, Cmd.none)

        ShowTaskDetails currentTask ->
          let
            tasks = model.filteredTaskList
                      |> List.map (\task -> if task.taskId == currentTask.taskId then {task | showDetails = True} else {task | showDetails = False} )
          in
           ({model | filteredTaskList = tasks}, getCommentsRequest currentTask.taskId)

        ToggleCreatorDropdown ->
          let
             newValue = if model.filterValues.showCreatorDropdown then False else True
             oldfilterValues = model.filterValues
             newfilterValues = { oldfilterValues | showCreatorDropdown =newValue}
          in
            ( {model |  filterValues = newfilterValues}  ,Cmd.none)

        FilterCreatorRecord user ->
         let
          filteredUser =
            List.filter (\x -> x.id == user.id) model.filterValues.selectedCreatorList

          newUserList =
            if List.isEmpty filteredUser then
                user :: model.filterValues.selectedCreatorList
            else
              List.filter (\x -> x.id /= user.id) model.filterValues.selectedCreatorList
          oldfilterValues = model.filterValues
          newfilterValues =
            { oldfilterValues | selectedCreatorList = newUserList}
         in
          ( { model | filterValues = newfilterValues } ,Cmd.none)

        ToggleOwnerDropdown ->
           let
              newValue = if model.filterValues.showOwnerDropdown then False else True
              oldfilterValues = model.filterValues

              newfilterValues =
                { oldfilterValues | showOwnerDropdown = newValue}
           in
            ( {model | filterValues = newfilterValues } ,Cmd.none)

        FilterOwnerRecord user ->
           let
            filteredUser =
              List.filter (\x -> x.id == user.id) model.filterValues.selectedOwnerList

            newUserList =
              if List.isEmpty filteredUser then
                  user :: model.filterValues.selectedOwnerList
              else
                List.filter (\x -> x.id /= user.id) model.filterValues.selectedOwnerList

            oldfilterValues = model.filterValues
            newfilterValues =
                { oldfilterValues | selectedOwnerList = newUserList}
           in
            ( { model | filterValues = newfilterValues } ,Cmd.none)




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
                            , label [] [text l.commentedOn]]
                            , button [ onClick (DeleteTask l)] [text "Delete"]
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
  let
    _ = Debug.log "task details===" task
  in
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
           --, div[class "button-collection"][button [ onClick (DeleteTask task.taskId)] [text "Delete"]
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
        "FilterTasks" ->
          True
        _ ->
          False
  in
  div[][
    div[class "header"][
    h1 [class "headerStyle"] [ text "Dashboard" ]
    , button [ onClick CreateTask ] [text "Create Task"]
    , button [ onClick ShowFilterPanel ] [text "Filter Tasks"]
    ]
    ,div [class "panel"]
      [
      renderDashboard model
      , if model.renderView == "CreateTask" then div [ classList [( "mini-panel", True), ("show", openSidePanel),  ("hide", not openSidePanel)] ][ renderCreateTaskView model ] else text ""
      , if model.renderView == "FilterTasks" then div [ classList [( "mini-panel", True), ("show", openSidePanel), ("hide", not openSidePanel)] ][ renderFilterView model ] else text ""
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

        , renderList (keep model.visibility model.filteredTaskList) model
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

renderFilterView: Model -> Html Msg
renderFilterView model =
  div []
      [ h1 [] [ text "Filter Tasks" ]
      , div[class "fieldset"][label [] [text "Title : "]
      , input [  placeholder ""
              , onInput InputFilterTitleSearchText  -- InputTask
              , value model.filterValues.titleSearchText
              ]
              []]
      , renderOwnerDropdown model
      , renderCreatorDropdown model

      , div[class "fieldset"][label [] [text "Due On : "]
      , input [  placeholder ""
              , onInput InputFilterDueDate  -- InputTask
              , value model.filterValues.due_date
              ]
              []]
      , div[class "fieldset"][label [] [text "Created On : "]
      , input [  placeholder ""
              , onInput InputFilterCreateDate  -- InputTask
              , value model.filterValues.create_date
              ]
              []]
      , div[class "button-collection"][ button [ class "primary", onClick ApplyFilter ] [text "Apply"]
      , button [ onClick CancelFilter ] [text "Cancel"]]
      ]

createTaskRequest : Task -> Cmd Msg
createTaskRequest task =
    Http.post
        { url = "http://172.15.3.11:9999/task-bucket-api/tasks"
        , body = Http.jsonBody (newTaskEncoder task)
        , expect = Http.expectJson TaskCreated taskDecoder
        --, timeout = Nothing
        --, withCredentials = False
        }
getTasksRequest : Cmd Msg
getTasksRequest =
  Http.get
      { url = "http://172.15.3.11:9999/task-bucket-api/tasks"
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
taskEncoder : Task -> JE.Value
taskEncoder task =
  let
    _ = log "task===" task
  in
    JE.object
        [ ( "id", JE.int task.taskId )
        , ( "title", JE.string task.title )
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

intDecoder : Json.Decoder ID
intDecoder =
    Json.succeed ID
        |> required "id" Json.int

deleteMessageDecoder : Json.Decoder Message
deleteMessageDecoder =
    Json.succeed Message
        |> required "message" Json.string


taskListDecoder : Json.Decoder (List Task)
taskListDecoder = Json.list taskDecoder

---- Code for Comment Sections ---


defaultComment : User -> Task ->  Comment
defaultComment  user task =
  Comment 0 task.taskId  task.title user.id

createCommentRequest : User -> Task -> Comment -> Cmd Msg
createCommentRequest user task comment =
   Http.post
       { url = "http://172.15.3.11:9999/task-bucket-api/tasks/"++ String.fromInt(task.taskId) ++"/comments"
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
       |> required "id" Json.int
       |> required "task_id" Json.int
       |> optional "text" Json.string ""
       |> optional "created_by" Json.int 1


getCommentsRequest : Int -> Cmd Msg
getCommentsRequest taskId =
 Http.get
     {
     url = "http://172.15.3.11:9999/task-bucket-api/tasks/" ++ String.fromInt(taskId) ++"/comments"
     , expect = Http.expectJson CommentsFetched commentListDecoder
     }

deleteTaskRequest : Task -> Cmd Msg
deleteTaskRequest task =
    Http.post
        { url = "http://172.15.3.11:9999/task-bucket-api/tasks/delete"
        , body = Http.jsonBody (taskEncoder task)
        , expect = Http.expectJson TaskDeleted deleteMessageDecoder
        --, timeout = Nothing
        --, withCredentials = False
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
     { url = "http://172.15.3.11:9999/task-bucket-api/users"
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


renderCreatorDropdown: Model -> Html Msg
renderCreatorDropdown model =
   let

          dropDownClass =
              "dropdown-select"
  in
  div [ class dropDownClass ]
                [ button
                    [
                     onClick ToggleCreatorDropdown
                     , class "selectedoption button"
                    , id "orgnode_dd"
                    ]
                    [ span [ class "overflowcontrol" ]
                        [ text "Select - Creator" ]
                    ]
                , ul
                    [ id "orgnode-dd-listbox"
                    , class "option"

                    , class "options nobullets"
                    , tabindex -1
                    ]
                    (if model.filterValues.showCreatorDropdown
                      then
                        (List.map
                            (\x ->
                                li
                                    [ attribute "aria-selected" "true"
                                    , class ""
                                    , onClick (FilterCreatorRecord x)
                                    , id (x.email ++ "_li_c")
                                    , attribute "role" "option"
                                    ]
                                    [ text x.name ]
                            )
                            model.userList
                        )
                    else
                      []
                    )
                ,ul []  (List.map (\x -> li[] [text x.name] ) model.filterValues.selectedCreatorList)
                ]




renderOwnerDropdown: Model -> Html Msg
renderOwnerDropdown model=
   let

          dropDownClass =
              "dropdown-select"
  in
  div [ class dropDownClass ]
                [ button
                    [
                     onClick ToggleOwnerDropdown
                     , class "selectedoption button"
                    , id "orgnode_dd"
                    ]
                    [ span [ class "overflowcontrol" ]
                        [ text "Select-Owner" ]
                    ]
                , ul
                    [ id "orgnode-dd-listbox"
                    , class "option"

                    , class "options nobullets"
                    , tabindex -1
                    ]
                    (if model.filterValues.showOwnerDropdown then
                    (List.map
                        (\x ->
                            li
                                [ attribute "aria-selected" "true"
                                , class ""
                                , onClick (FilterOwnerRecord x)
                                , id (x.email ++ "_li")
                                , attribute "role" "option"
                                ]
                                [ text x.name ]
                        )
                        model.userList
                    )
                    else
                    [])
                ,ul []  (List.map (\x -> li[] [text x.name] ) model.filterValues.selectedOwnerList)
                ]
