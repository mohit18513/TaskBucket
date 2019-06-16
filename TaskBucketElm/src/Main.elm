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
import Task exposing (Task)

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
        , view = \model -> { title = "Task Bucket", body = [view model] }
        , update = update
        , subscriptions = \_ -> Sub.none
        }
    --beginnerProgram { model = model, view = view1, update = update1 }

init : Maybe Model -> ( Model, Cmd Msg )
init maybeModel =
  ( Maybe.withDefault emptyModel maybeModel
  , Cmd.none --Cmd.batch [ getTasksRequest, getUsersRequest ]
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
  , imageurl : String
  }

type alias LoginUser =
  { userEmail : String
  , userPassword : String
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
    , tempCreatTaskOwnerName : String
    , loginUser : LoginUser
    }

type alias Comment =
    { commentId : Int
    , taskId :  Int
    , text  :  String
    , createdBy : Int
    , createTime : String
    }

type alias FilterValues =
    { due_date : String
    , create_date : String
    , createdBy : Int
    , last_comment_date : String
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
      , filterValues = { due_date = ""
                        , create_date = ""
                        , createdBy = 1
                        , last_comment_date = ""
                        , titleSearchText = ""
                        , showCreatorDropdown = False
                        , selectedCreatorList = []
                        , showOwnerDropdown = False
                        , selectedOwnerList = []
                      }
      , tempCreatTaskOwnerName = ""
      , loginUser = emptyLoginUser
    }

emptyTask : Task
emptyTask =
    { taskId = 1
    , title = ""
    , description = ""
    , created_by = 1
    , ownerId = 1
    , status = 0
    , due_date = ""
    , createdOn = ""
    , commentedOn = ""
    , isTaskDeleted = False
    , isTaskCompleted = False
    , showDetails = False
    }


emptyUser: User
emptyUser =
  { id = 0
  , name = ""
  , email = ""
  , imageurl = ""
  }

emptyLoginUser: LoginUser
emptyLoginUser =
  { userEmail = ""
  , userPassword = ""
  }



-- UPDATE


type Msg
    = AddTask
    | CreateTask
    | UpdateTask
    | ShowFilterPanel
    | InputTaskTitle String
    | InputDescription String
    | InputTaskDueDate String
    | SetCreateTaskOwner User
    | UpdateTaskStatus Int
    | CancelTask
    | DeleteTask Task
    | ShowEditTaskPanel Task
    | MarkItCompleted Int
    | SwitchVisibility String
    | TaskCreated (Result Http.Error Task)
    | TaskUpdated (Result Http.Error Task)
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
    | InputFilterLastCommentDate String
    | InputFilterTitleSearchText String
    | ToggleCreatorDropdown
    | FilterCreatorRecord User
    | ToggleOwnerFilterDropdown
    | FilterOwnerRecord User
    | EnterUseEmail String
    | EnterUserPassword String
    | Login
    | UserLoggedIn (Result Http.Error User)
    | LogOut

--type Visibility = All | New | InProgress | Completed | Cancelled

--port setStorage : Model -> Cmd msg

--    | ClearThis String

-- updateWithStorage : Msg -> Model -> ( Model, Cmd Msg )
-- updateWithStorage msg model =
--     let
--         ( newModel, cmds ) =
--             update msg model
--     in
--         ( newModel
--         , Cmd.batch [ setStorage newModel, cmds ]
--         )



update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AddTask ->
            (model, createTaskRequest model.newTask )
        CreateTask ->
          let
            _ = Debug.log "newTask==" model.newTask
          in
            ({model | renderView = "CreateTask", newTask = emptyTask, tempCreatTaskOwnerName = ""}, Cmd.none )
        UpdateTask ->
            let
              _ = Debug.log "UpdateTask ==" model.newTask
            in
              (model, updateTaskRequest model.newTask )
        ShowFilterPanel ->
          let
            _ = Debug.log "showFilterPanel==" ""
          in
            ({model | renderView = "FilterTasks"}, Cmd.none )
        InputTaskTitle title ->
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
        SetCreateTaskOwner owner ->
          let
            _ = Debug.log "SetCreateTaskOwnerId ===" owner.name
            task = model.newTask
            newTask = {task | ownerId = owner.id}
          in
            ({model | newTask = newTask, tempCreatTaskOwnerName = owner.name}, Cmd.none)
        InputTaskDueDate due_date ->
          let
            task = model.newTask
            newTask = {task | due_date = due_date}
          in
            ({model | newTask = newTask}, Cmd.none)

        UpdateTaskStatus status ->
          let
            _ = Debug.log "UpdateTaskStatus; newTask values ==" model.newTask
            task = model.newTask
            newTask = {task | status = status}
          in
            ({model | newTask = newTask}, Cmd.none)

        CancelTask ->
          ({model | renderView = "Dashboard", newTask= emptyTask}, Cmd.none)

        DeleteTask taskToBeDeleted ->
          let
            taskList = List.filter (\task -> task.taskId /= taskToBeDeleted.taskId) model.taskList
          in
            ({ model
                | taskCount = model.taskCount
                , taskList = taskList
                , filteredTaskList = taskList
            }, deleteTaskRequest taskToBeDeleted)

        ShowEditTaskPanel taskToBeEdited ->
          let
            _ = Debug.log "ShowEditTaskPanel==" model.newTask
            newTask = taskToBeEdited
            taskToBeUpdated = {newTask | taskId = taskToBeEdited.taskId}
            taskOwnerName = getUserName model.userList taskToBeEdited.ownerId
          in
            ({model | renderView = "ShowEditTaskPanel"
                    , newTask = taskToBeUpdated
                    , tempCreatTaskOwnerName = taskOwnerName
             }
            , Cmd.none )

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
            let
              _ = Debug.log "SwitchVisibility" visibility
            in
              ({ model
                  | visibility = visibility
              }, Cmd.none)

        TaskCreated (Ok task) ->
            ( {model | taskList = [task] ++ model.taskList, renderView = "Dashboard", newTask = emptyTask}, Task.perform (\_ -> CancelFilter ) (Task.succeed ()) )

        TaskCreated (Err err) ->
          let
            _ = Debug.log "Error TaskCreated==" err
          in
            ( model, Cmd.none )

        TaskUpdated (Ok task) ->
          -- let
          --   taskList = List.map (\t -> if t.taskId == task.taskId then task else t) model.taskList
          -- in
          --   ( {model | taskList = taskList, renderView = "Dashboard", newTask = emptyTask}, Task.perform (\_ -> CancelFilter ) (Task.succeed ()) )
          let
            _ = Debug.log "TaskUpdated Ok; model.taskList==" task
            _ = Debug.log "TaskUpdated Ok; model.taskList==" model.taskList
            taskList = List.map (\t -> if t.taskId == task.taskId then task else t) model.taskList
            _ = Debug.log "TaskUpdated Ok;       taskList==" taskList
          in
            ( {model | taskList = taskList, renderView = "Dashboard", newTask = emptyTask}
            , Task.perform (\_ -> CancelFilter ) (Task.succeed ())
            )

        TaskUpdated (Err err) ->
          let
            _ = Debug.log "Error TaskUpdated==" err
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
          let
            _ = Debug.log "Ok comment : " comment
          in
            ( {model | renderView ="Dashboard" }, Cmd.batch [ getTasksRequest, getCommentsRequest comment.taskId] )

        CommentCreated (Err err) ->
          let
            _ = Debug.log "Error CommentCreated fecthed===" err
          in
            ( model, Cmd.none )

        InputCommentText description ->
         let
           comment = model.currentComment
           newComment = {comment | text = description, createdBy = (getUserId model.userList model.loginUser.userEmail)
                        }
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
        InputFilterLastCommentDate last_comment_date ->
         let
           _ = Debug.log "InputFilterLastCommentDate ===" last_comment_date
           filterValues = model.filterValues
           filterValuesUpdated = {filterValues | last_comment_date = last_comment_date}
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
                List.filter (\task -> String.contains model.filterValues.create_date task.createdOn) tempFilteredTaskList

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

            temp4FilteredTaskList =
              if model.filterValues.last_comment_date == "" then
                temp3FilteredTaskList
              else
                List.filter (\task -> String.contains model.filterValues.last_comment_date task.commentedOn) temp3FilteredTaskList

          in
            ({ model
                | filteredTaskList = temp4FilteredTaskList
            }, Cmd.none)
        CancelFilter ->
          let
            _ = Debug.log "CancelFilter ===" ""
          in
           ({model | filteredTaskList = model.taskList
                    , renderView = "Dashboard"
                    , filterValues = emptyModel.filterValues}, Cmd.none)

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

        ToggleOwnerFilterDropdown ->
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

        EnterUseEmail userEmail ->
          let
            loginUser = model.loginUser
            updatedLoginUser = {loginUser | userEmail = userEmail}
          in
            ({model | loginUser = updatedLoginUser}, Cmd.none)
        EnterUserPassword userPassword ->
          let
            loginUser = model.loginUser
            updatedLoginUser = {loginUser | userPassword = userPassword}
          in
            ({model | loginUser = updatedLoginUser}, Cmd.none)
        Login ->
          (model, logInUserRequest model.loginUser)
        UserLoggedIn  (Ok user) ->
            ( {model | user = user}, Cmd.batch [ getTasksRequest, getUsersRequest ] )

        UserLoggedIn (Err err) ->
          let
            _ = Debug.log "Error UserLoggedIn===" err
          in
            ( model, Cmd.none )
        LogOut ->
            ({model | loginUser = emptyLoginUser, user = emptyUser}, Cmd.none)






keep : String -> List Task -> List Task
keep visibility taskList =
  case visibility of
      "New" ->
        List.filter (\task -> task.status == 0) taskList
      "InProgress" ->
        List.filter (\task -> task.status == 1) taskList
      "Completed" ->
        List.filter (\task -> task.status == 2) taskList
      "Cancelled" ->
        List.filter (\task -> task.status == 3) taskList
      _ ->
        taskList

renderList lst model =
    ol []
        (List.map
            (\l ->
                li []
                    [ div [ class "list-item" ]
                        [ div [ class "list-header" ]
                            [ div [ onClick (ShowTaskDetails l) ]
                                [ label [] [ text "Title: " ]
                                , span [] [ text l.title ]
                                , div [ class "status" ]
                                    [ span [ class (getStatus l.status) ] [ text (getStatus l.status) ]
                                    ]
                                , if l.commentedOn == ""
                                    then
                                      text ""
                                    else
                                      div [ class "comment" ]
                                        [ label [] [ text "  Commented On: " ]
                                        , span [] [ text l.commentedOn ]
                                        ]
                                , button [ class "delete1", onClick (DeleteTask l) ] [ text "Delete" ]
                                , button [ class "delete2", onClick (ShowEditTaskPanel l) ] [ text "Edit" ]
                                ]
                            --, button [ class "button-tertiary", onClick (AddComment (defaultComment model.user l))][text "Add Comment"]]
                            --, button [ class "button-tertiary", onClick (CreateComment l) ][text "Add Comment"]
                            --, button [ class "button-tertiary", onClick (FetchComments  l)][text "Show Comments"]]
                            , if l.showDetails then
                                renderTaskDetails l model

                              else
                                text ""
                            ]
                        ]
                    ]
            )
            lst
        )

renderTaskComments : List Comment -> List User -> Html msg
renderTaskComments comments userList =
        ol []
        (List.map
            (\comment ->
                li []
                    [ div [ class "list-item" ]
                        [ div [ class "list-header" ]
                            [ div []
                                [ img [src (getUserImgUrl userList comment.createdBy), width 30, height 30] []
                                , textarea [disabled True] [ text comment.text ]
                                , div []
                                    [
                                    -- text "Added by "
                                    -- , text (getUserImgUrl userList comment.createdBy)
                                    -- , img [src "/assets/User.ico", width 30, height 30] []
                                    -- , text " on "
                                    --,
                                    text comment.createTime

                                    ]
                                ]
                            ]
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
            [ label [] [text "  Description: "]
            , span [] [text (task.description)]
            , div [][ label [][ text "Owner: "]
            , label [] [text (getUserName model.userList task.ownerId)]]
            , div [][ label [][ text "  Due Date: "]
            , label [] [text task.due_date]]
            , div [] [ label [][ text "  Created By: "]
            , label [] [text (getUserName model.userList task.created_by)]]
            , div [][ label [][ text "  Created On: "]
            , label [] [text task.createdOn]]
            ]
           --, a [onClick (ShowTaskDetails task)] [text task.title]
           --, div[class "button-collection"][button [ onClick (DeleteTask task.taskId)] [text "Delete"]
           --, button [ class "button", onClick (AddComment (defaultComment model.user l))][text "Add Comment"]]
           , if model.renderView == "CreateComment" then div [ ][ renderCreateCommentView model ] else div [][ img [title "Create Comment", src "http://pngimg.com/uploads/plus/plus_PNG122.png", width 30, height 30, onClick (CreateComment task)] []]
           , renderTaskComments model.commentList model.userList  --button [ class "button", onClick (FetchComments task)][text "Show Comments"]
           ]
           -- ,div[class "body"][
           --   text "body here"
           -- ]

getUserId : List User -> String -> Int
getUserId  users email =
  let
    user = users
      |> List.filter( \u -> u.email == email)
      |> List.head
      |> Maybe.withDefault emptyUser
  in
    user.id

getUserName : List User -> Int -> String
getUserName  users id =
  let
    user = users
      |> List.filter( \u -> u.id == id)
      |> List.head
      |> Maybe.withDefault emptyUser
  in
    user.name

getUserImgUrl : List User -> Int -> String
getUserImgUrl  users id =
    let
      _ = Debug.log "userlist ========" users
      user = users
        |> List.filter( \u -> u.id == id)
        |> List.head
        |> Maybe.withDefault emptyUser
    in
      user.imageurl

-- VIEW


view : Model -> Html Msg
view model =
  let
    openSidePanel=
      case model.renderView of
        "CreateTask" ->
          True
        "ShowEditTaskPanel" ->
          True
        "CreateComment" ->
          True
        "FilterTasks" ->
          True
        _ ->
          False
    isUserNotLoggedIn = model.user == emptyUser
  in
  if isUserNotLoggedIn then loginView model else div[][
    div[class "header"][
    h1 [class "headerStyle"] [ text "Task bucket" ]
    , h2 [class "headerStyle"] [ text ("Welcome : " ++ (getUserName model.userList model.user.id)) ]
    , button [ onClick CreateTask, class "btn-secondary" ] [text "Create Task"]
    , button [ onClick ShowFilterPanel, class "btn-secondary" ] [text "Filter Tasks"]
    , button [ onClick LogOut ] [text "LogOut"]
    ]
    ,div [class "panel"]
      [
      renderDashboard model
      , if model.renderView == "CreateTask" then div [ classList [( "mini-panel", True), ("show", openSidePanel),  ("hide", not openSidePanel)] ][ renderCreateTaskView model ] else text ""
      , if model.renderView == "ShowEditTaskPanel" then div [ classList [( "mini-panel", True), ("show", openSidePanel),  ("hide", not openSidePanel)] ][ renderShowEditTaskPanelView model ] else text ""
      , if model.renderView == "FilterTasks" then div [ classList [( "mini-panel", True), ("show", openSidePanel), ("hide", not openSidePanel)] ][ renderFilterView model ] else text ""
        ]
      ]

loginView : Model -> Html Msg
loginView model =
  div []
    [ div [][ img [src "/assets/WTM_logo.jpg", width 300, height 300] []]
    , span [class "taskBucket"][ text "Task Bucket"]
    , div [][ label [] [text "UserName: "]
    , input [  placeholder "Enter Your Email Id"
            , onInput EnterUseEmail
            , value model.loginUser.userEmail
            ]
            []]
    , div [] [label [] [text "Password: "]
    , input [ onInput EnterUserPassword
            , type_ "password"
            , value model.loginUser.userPassword
            ]
            []]
    , div [] [ button [onClick Login ]
            [text "Login"]]


    ]
renderDashboard: Model -> Html Msg
renderDashboard model =
    div [class "main-panel"]
        [ h2 [class "headerStyle"] [ text "My Tasks" ]
        , div [class "filter"]
              [ radio "All" (SwitchVisibility "All") (if model.visibility == "All" then True else False)
              , radio "New" (SwitchVisibility "New") (if model.visibility == "New" then True else False)
              , radio "In_Progress" (SwitchVisibility "InProgress") (if model.visibility == "InProgress" then True else False)
              , radio "Completed" (SwitchVisibility "Completed") (if model.visibility == "Completed" then True else False)
              , radio "Cancelled" (SwitchVisibility "Cancelled") (if model.visibility == "Cancelled" then True else False)
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
      , input [  placeholder "Title"
              , onInput InputTaskTitle
              , value model.newTask.title
              ]
              []]
      , div[class "fieldset"][label [] [text "Description"]
      , textarea [ onInput InputDescription , value model.newTask.description
              ]
              []
              ]
      , renderCreateTaskOwnerDropdown model
      , div[class "fieldset"][label [] [text "Due Date"]
      , input [  placeholder "YYYY-MM-DD"
              , onInput InputTaskDueDate
              , value model.newTask.due_date
              ]
              []]
      ,div[class "button-collection"][ button [ class "primary", onClick AddTask ] [text "Create"]
      , button [ onClick CancelTask ] [text "Cancel"]]
      ]


renderShowEditTaskPanelView: Model -> Html Msg
renderShowEditTaskPanelView model =
  div []
      [ h1 [] [ text "Edit Task" ]
      , div[class "fieldset"][label [] [text "Title"]
      , input [  placeholder ""
              , onInput InputTaskTitle
              , value model.newTask.title
              ]
              []]
      , div [class "filter1"]
            [ radio "New" (UpdateTaskStatus 0) (if model.newTask.status == 0 then True else False)
            , radio "In-Progress" (UpdateTaskStatus 1) (if model.newTask.status == 1 then True else False)
            , radio "Completed" (UpdateTaskStatus 2) (if model.newTask.status == 2 then True else False)
            , radio "Cancelled" (UpdateTaskStatus 3) (if model.newTask.status == 3 then True else False)
            ]
      , div[class "fieldset"][label [] [text "Description"]
      , textarea [ onInput InputDescription , value model.newTask.description
              ]
              []
              ]
      , renderCreateTaskOwnerDropdown model
      , div[class "fieldset"][label [] [text "Due Date"]
      , input [  placeholder "YYYY-MM-DD"
              , onInput InputTaskDueDate
              , value model.newTask.due_date
              ]
              []]
      ,div[class "button-collection"][ button [ class "primary", onClick UpdateTask ] [text "Update"]
      , button [ onClick CancelTask ] [text "Cancel"]]
      ]


renderFilterView: Model -> Html Msg
renderFilterView model =
  div []
      [ h1 [] [ text "Filter Tasks" ]
      , div[class "fieldset"][label [] [text "Title : "]
      , input [  placeholder ""
              , onInput InputFilterTitleSearchText
              , value model.filterValues.titleSearchText
              ]
              []]
      , renderOwnerDropdown model
      , renderCreatorDropdown model

      , div[class "fieldset"][label [] [text "Due On : "]
      , input [ placeholder "YYYY-MM-DD"
              , onInput InputFilterDueDate
              , value model.filterValues.due_date
              ]
              []]
      , div[class "fieldset"][label [] [text "Created On : "]
      , input [ placeholder "YYYY-MM-DD"
              , onInput InputFilterCreateDate
              , value model.filterValues.create_date
              ]
              []]
      , div[class "fieldset"][label [] [text "Last Comment On : "]
      , input [ placeholder "YYYY-MM-DD"
              , onInput InputFilterLastCommentDate
              , value model.filterValues.last_comment_date
              ]
              []]
      , div[class "button-collection"][ button [ class "primary", onClick ApplyFilter ] [text "Apply"]
      , button [ onClick CancelFilter ] [text "Cancel"]]
      ]

createTaskRequest : Task -> Cmd Msg
createTaskRequest task =
    Http.post
        { url = "https://reportstesting1.tk20.com/taskbucketapi/task-bucket-api/tasks"
        , body = Http.jsonBody (newTaskEncoder task)
        , expect = Http.expectJson TaskCreated taskDecoder
        --, timeout = Nothing
        --, withCredentials = False
        }

updateTaskRequest : Task -> Cmd Msg
updateTaskRequest task =
    let
      _ = Debug.log "task in updateTaskRequest ===" task
    in
      Http.post
        { url = "https://reportstesting1.tk20.com/taskbucketapi/task-bucket-api/tasks/"++ String.fromInt(task.taskId)
        , body = Http.jsonBody (newTaskEncoder task)
        , expect = Http.expectJson TaskUpdated taskDecoder
        --, timeout = Nothing
        --, withCredentials = False
        }

getTasksRequest : Cmd Msg
getTasksRequest =
  Http.get
      { url = "https://reportstesting1.tk20.com/taskbucketapi/task-bucket-api/tasks"
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
        [ ( "id", JE.int task.taskId )
        , ( "title", JE.string task.title )
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
        |> optional "due_date" Json.string ""
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
  Comment 0 task.taskId task.title user.id ""

createCommentRequest : User -> Task -> Comment -> Cmd Msg
createCommentRequest user task comment =
   Http.post
       { url = "https://reportstesting1.tk20.com/taskbucketapi/task-bucket-api/tasks/"++ String.fromInt(task.taskId) ++"/comments"
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
       |> optional "createtime" Json.string ""

getCommentsRequest : Int -> Cmd Msg
getCommentsRequest taskId =
 Http.get
     {
     url = "https://reportstesting1.tk20.com/taskbucketapi/task-bucket-api/tasks/" ++ String.fromInt(taskId) ++"/comments"
     , expect = Http.expectJson CommentsFetched commentListDecoder
     }

deleteTaskRequest : Task -> Cmd Msg
deleteTaskRequest task =
    Http.post
        { url = "https://reportstesting1.tk20.com/taskbucketapi/task-bucket-api/tasks/delete"
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
     [ label [] [ text "Create Comment: " ]
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
       |> optional "imageurl" Json.string ""

logInUserEncoder : LoginUser -> JE.Value
logInUserEncoder loginUser =
  let
    _ = log "loginUser===" loginUser
  in
    JE.object
        [ ( "email", JE.string loginUser.userEmail )
        , ( "pwd", JE.string loginUser.userPassword )
        ]

logInUserRequest : LoginUser -> Cmd Msg
logInUserRequest loginUser =
    Http.post
        { url = "https://reportstesting1.tk20.com/taskbucketapi/task-bucket-api/login"
        , body = Http.jsonBody (logInUserEncoder loginUser)
        , expect = Http.expectJson UserLoggedIn userDecoder
        --, timeout = Nothing
        --, withCredentials = False
        }

getUsersRequest : Cmd Msg
getUsersRequest =
 Http.get
     { url = "https://reportstesting1.tk20.com/taskbucketapi/task-bucket-api/users"
     , expect = Http.expectJson UsersFetched userListDecoder
     }

userListDecoder : Json.Decoder (List User)
userListDecoder = Json.list userDecoder

getStatus : Int -> String
getStatus status =
  case status of
    0 -> "New"
    1 -> "In-Progress"
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
                ,ul [class "selected_option"]  (List.map (\x -> li[] [text x.name] ) model.filterValues.selectedCreatorList)
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
                     onClick ToggleOwnerFilterDropdown
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
                ,ul [class "selected_option"]  (List.map (\x -> li[] [text x.name] ) model.filterValues.selectedOwnerList)
                ]

renderCreateTaskOwnerDropdown: Model -> Html Msg
renderCreateTaskOwnerDropdown model=
  let
     dropDownClass = "dropdown-select"
  in
  div [ class "dropDownClass textareaBtn" ]
               [ button
                   [
                    class "selectedoption button"
                   , id "orgnode_dd"
                   ]
                   [ span [ class "overflowcontrol" ]
                       [ text "Select-Owner"]
                   ]
               , span[ class "selectedOwner"][text model.tempCreatTaskOwnerName]
               , ul
                   [ id "orgnode-dd-listbox"
                   , class "option"
                   , class "options nobullets"
                   , tabindex -1
                   ]
                   (List.map
                       (\x ->
                           li
                               [ attribute "aria-selected" "true"
                               , class ""
                               , onClick (SetCreateTaskOwner x)
                               , id (x.email ++ "_li")
                               , attribute "role" "option"
                               ]
                               [ text x.name ]
                       )
                       model.userList
                   )
               ,ul []  (List.map (\x -> li[] [text x.name] ) model.filterValues.selectedOwnerList)
               ]
