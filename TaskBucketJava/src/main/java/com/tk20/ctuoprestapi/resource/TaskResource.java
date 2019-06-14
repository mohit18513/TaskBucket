package main.java.com.tk20.ctuoprestapi.resource;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashSet;
import java.util.Set;

import javax.sql.DataSource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

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
	public Set<Task> getTasks(@RequestParam String user_id) {

		ResultSet taskCursor = null;
		Set<Task> tasks = new HashSet<>();
		ResultSet assessorCursor = null;
		try (Connection con = dataSource.getConnection()) {
			String taskQuery = "select * from tasks;";
			// String taskQuery = "select * from tasks ts, task_user tu where ;";
			PreparedStatement pstmt = con.prepareStatement(taskQuery);
			System.out.println("Query Created..");
			taskCursor = pstmt.executeQuery();
			System.out.println("Query Executed..");
			Task task = null;
			while (taskCursor.next()) {
				task = new Task();
				task.setId(taskCursor.getString("id"));
				task.setTitle(taskCursor.getString("title"));
				task.setDescription(taskCursor.getString("description"));
				task.setDue_date(Date.valueOf(taskCursor.getString("setdue_date")));
				task.setCreated_by(taskCursor.getString("created_by"));
				task.setOwner(taskCursor.getString("owner"));
				task.setStatus(taskCursor.getString("status"));
				task.setLast_commented_on(Date.valueOf(taskCursor.getString("last_commented_on")));
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

}
