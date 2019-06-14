package main.java.com.tk20.ctuoprestapi.resource;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.HashSet;
import java.util.Set;

import javax.sql.DataSource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.google.common.base.Throwables;

import main.java.com.ExceptionHandlers.ApplicationException;
import main.java.com.responses.ResponseSuccess;
import main.java.com.tk20.Entities.Task;
import main.java.com.tk20.services.Logger;

@RestController
@RequestMapping(path = "/task-bucket-api/tasks")
public class TaskResource {

	// @Autowired
	// JDBCTemplateQueryExecutor jDBCTemplateQueryExecutor;
	@Autowired
	Logger logger;
	@Autowired
	DataSource dataSource = null;

	@CrossOrigin(origins = "*")
	@GetMapping("")
	public Set<Task> getTasks(@RequestParam Integer user_id) {

		ResultSet taskCursor = null;
		Set<Task> tasks = new HashSet<>();
		ResultSet assessorCursor = null;
		try (Connection con = dataSource.getConnection()) {
			String taskQuery = "select * from tasks where id=?;";
			// String taskQuery = "select * from tasks ts, task_user tu where ;";
			PreparedStatement pstmt = con.prepareStatement(taskQuery);
			pstmt.setInt(1, user_id);
			System.out.println("Query Created..");
			taskCursor = pstmt.executeQuery();
			System.out.println("Query Executed..");
			Task task = null;
			while (taskCursor.next()) {
				task = new Task();
				task.setId(taskCursor.getString("id"));
				task.setTitle(taskCursor.getString("title"));
				task.setDescription(taskCursor.getString("description"));
				task.setDue_date(taskCursor.getTimestamp("due_date"));
				task.setCreated_by(taskCursor.getString("created_by"));
				task.setOwner(taskCursor.getString("owner"));
				task.setStatus(taskCursor.getInt("status"));
				task.setLast_commented_on(taskCursor.getTimestamp("last_commented_on"));
				tasks.add(task);
			}

		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		finally {
			try {
				if (taskCursor != null)
					taskCursor.close();
				if (assessorCursor != null)
					assessorCursor.close();
			} catch (SQLException ex2) {
			}
		}
		return tasks;
	}

	@CrossOrigin(origins = "*")
	@PostMapping("")
	@ResponseStatus(value = HttpStatus.ACCEPTED, reason = "Task Created Successfully")
	public void createTasks(Task task) {

		System.out.println(task.getStatus());
		// String sql = "INSERT INTO tasks (title , description, due_date, created_by,
		// owner , status ) values(?,?,?,?,?,?)";
		//
		// try (Connection conn = this.connect(); PreparedStatement pstmt =
		// conn.prepareStatement(sql)) {
		// pstmt.setString(1, title);
		// pstmt.setString(2, description);
		// String timestamp = "2019-06-13 24:00:01";
		// Timestamp ti = Timestamp.valueOf(timestamp);
		// pstmt.setTimestamp(3, ti);
		// pstmt.setInt(4, created_by);
		// pstmt.setInt(5, owner);
		// pstmt.setInt(6, status);
		// pstmt.executeUpdate();
		// } catch (SQLException e) {
		// System.out.println(e.getMessage());
		// throw new ApplicationException(Throwables.getStackTraceAsString(e),
		// e.getMessage());
		// }
	}

	@CrossOrigin(origins = "*")
	@PutMapping("")
	public ResponseEntity<String> updateTasks(@RequestParam String title, @RequestParam String description,
			@RequestParam Integer created_by, @RequestParam Integer owner, @RequestParam Integer status) {

		// if()
		String sql = "update tasks set title = ?, description = ?, due_date = ?, created_by = ?, owner =?, status =? )  values(?,?,?,?,?,?)";

		try (Connection conn = this.connect(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setString(1, title);
			pstmt.setString(2, description);
			String timestamp = "2019-06-13 24:00:01";
			Timestamp ti = Timestamp.valueOf(timestamp);
			pstmt.setTimestamp(3, ti);
			pstmt.setInt(4, created_by);
			pstmt.setInt(5, owner);
			pstmt.setInt(6, status);
			pstmt.executeUpdate();
		} catch (SQLException e) {
			System.out.println(e.getMessage());
			throw new ApplicationException(Throwables.getStackTraceAsString(e), e.getMessage());
		}
		return new ResponseSuccess(HttpStatus.ACCEPTED);
	}

	private Connection connect() {
		Connection conn = null;
		try {
			conn = dataSource.getConnection();
		} catch (SQLException e) {
			System.out.println(e.getMessage());
			throw new ApplicationException(Throwables.getStackTraceAsString(e), e.getMessage());
		}
		return conn;
	}

}
