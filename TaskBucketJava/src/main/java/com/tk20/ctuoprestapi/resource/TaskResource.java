package main.java.com.tk20.ctuoprestapi.resource;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import javax.sql.DataSource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.google.common.base.Throwables;

import main.java.com.ExceptionHandlers.ApplicationException;
import main.java.com.ExceptionHandlers.InvalidMethodRequestException;
import main.java.com.tk20.Entities.Contributor;
import main.java.com.tk20.Entities.Task;
import main.java.com.tk20.services.Logger;
import main.java.com.tk20.services.SendEmail;

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
	public ArrayList<Task> getTasks() {

		ResultSet taskCursor = null;
		ArrayList<Task> tasks = new ArrayList<Task>();
		ResultSet assessorCursor = null;
		try (Connection con = dataSource.getConnection()) {
			String taskQuery = "select * from tasks order by createtime desc;";
			PreparedStatement pstmt = con.prepareStatement(taskQuery);
			System.out.println("Get Query Created..");
			taskCursor = pstmt.executeQuery();
			System.out.println("Get Query Executed..");
			Task task = null;
			ResultSet contibutorCursor = null;
			ArrayList<Contributor> contributorList = null;
			while (taskCursor.next()) {
				task = new Task();
				contributorList = new ArrayList<Contributor>();
				task.setId(taskCursor.getInt("id"));
				task.setTitle(taskCursor.getString("title"));
				task.setDescription(taskCursor.getString("description"));
				task.setDue_date(taskCursor.getTimestamp("due_date"));
				task.setCreated_by(taskCursor.getInt("created_by"));
				task.setOwner(taskCursor.getInt("owner"));
				task.setStatus(taskCursor.getInt("status"));
				task.setLast_commented_on(taskCursor
						.getTimestamp("last_commented_on"));
				task.setCreatetime(taskCursor.getTimestamp("createtime"));

				String contibutorQuery = "select distinct owner from task_user where tasks = "
						+ task.getId() + ";";
				contibutorCursor = con.prepareStatement(contibutorQuery)
						.executeQuery();
				Contributor contributor;
				while (contibutorCursor.next()) {
					contributor = new Contributor();
					contributor
							.setContributor(contibutorCursor.getInt("owner"));
					contributorList.add(contributor);
				}
				task.setContributorList(contributorList);
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
	@PostMapping(path = "", consumes = MediaType.APPLICATION_JSON_VALUE)
	public Task createTasks(@RequestBody Task task) {

		String sql = "INSERT INTO tasks (title , description, due_date, created_by, owner , status,createtime ) values(?,?,?,?,?,?,now())";
		ResultSet taskCursor = null;
		PreparedStatement pstmt2 = null;
		ResultSet ownerAndContrinutorCursor = null;
		PreparedStatement pstmt3 = null;
		try (Connection conn = this.connect();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setString(1, task.getTitle());
			pstmt.setString(2, task.getDescription());
			pstmt.setTimestamp(3, task.getDue_date());
			pstmt.setInt(4, task.getCreated_by());
			pstmt.setInt(5, task.getOwner());
			pstmt.setInt(6, task.getStatus());
			pstmt.executeUpdate();

			List<Contributor> contributorList = null;
			if (task.getContributorList() != null
					&& task.getContributorList().size() != 0) {
				String insertSQL = "INSERT INTO task_user (owner, tasks, createtime ) VALUES (?, ?, now())";
				try {
					pstmt2 = conn.prepareStatement(insertSQL);
					contributorList = new ArrayList<Contributor>();
					for (Contributor contributor : task.getContributorList()) {
						contributorList.add(contributor);
						pstmt2.setInt(1, contributor.getContributor());
						pstmt2.setInt(2, task.getCreated_by());
						pstmt2.addBatch();
					}
					pstmt2.executeBatch(); // insert remaining records
					pstmt2.close();
				} catch (Exception e) {
					e.printStackTrace();
				}
			}

			String taskQuery = "select * from tasks order by createtime desc limit 1;";
			pstmt2 = conn.prepareStatement(taskQuery);
			// pstmt.setInt(1, user_id);
			taskCursor = pstmt2.executeQuery();
			task = new Task();
			while (taskCursor.next()) {
				task.setId(taskCursor.getInt("id"));
				task.setTitle(taskCursor.getString("title"));
				task.setDescription(taskCursor.getString("description"));
				task.setDue_date(taskCursor.getTimestamp("due_date"));
				task.setCreated_by(taskCursor.getInt("created_by"));
				task.setOwner(taskCursor.getInt("owner"));
				task.setStatus(taskCursor.getInt("status"));
				task.setLast_commented_on(taskCursor
						.getTimestamp("last_commented_on"));
				task.setCreatetime(taskCursor.getTimestamp("createtime"));
				task.setContributorList(contributorList);
			}
			if (pstmt2 != null)
				pstmt2.close();

			String ownerAndContrinutorQuery = "select distinct u.email as email from tasks t, users u where u.id = t.owner and t.id="
					+ task.getId()
					+ " union select distinct u2.email as email from tasks t, users u2, task_user tu where u2.id = tu.owner and tu.tasks = t.id  and t.id="
					+ task.getId() + ";";
			HashSet<String> emailSet = new HashSet<String>();
			;
			String emailBody = "The description for the task goes as follows: "
					+ task.getDescription();
			pstmt3 = conn.prepareStatement(ownerAndContrinutorQuery);
			ownerAndContrinutorCursor = pstmt3.executeQuery();
			while (ownerAndContrinutorCursor.next()) {
				emailSet.add(ownerAndContrinutorCursor.getString("email"));
			}

			if (pstmt3 != null)
				pstmt3.close();

			if (!emailSet.isEmpty())
				SendEmail.send(emailBody, emailSet, "support@taskbucket.in",
						"A new task " + task.getTitle()
								+ " is assigned to you.");

		} catch (SQLException e) {
			System.out.println(e.getMessage());
			throw new ApplicationException(Throwables.getStackTraceAsString(e),
					e.getMessage());
		} finally {

		}
		return task;
	}

	@CrossOrigin(origins = "*")
	@PutMapping("")
	@ResponseStatus(value = HttpStatus.ACCEPTED, reason = "Task Updated Successfully")
	public void updateTasks(@RequestBody Task task) {

		// if()
		String sql = "UPDATE tasks SET title = ?, description = ?, due_date = ?, owner =?, status =?, updatetime =now() where id="
				+ task.getId() + ";";

		PreparedStatement pstmt2 = null;
		try (Connection conn = this.connect();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setString(1, task.getTitle());
			pstmt.setString(2, task.getDescription());
			pstmt.setTimestamp(3, task.getDue_date());
			pstmt.setInt(4, task.getOwner());
			pstmt.setInt(5, task.getStatus());
			System.out.println(pstmt);
			if (pstmt.executeUpdate() == 0)
				throw new InvalidMethodRequestException();

			if (task.getContributorList() != null
					&& task.getContributorList().size() != 0) {
				String deleteSQL = "DELETE FROM task_user WHERE tasks = ?;";
				pstmt2 = conn.prepareStatement(deleteSQL);
				pstmt2.setInt(1, task.getId());
				pstmt2.executeUpdate();

				String insertSQL = "INSERT INTO task_user (owner, tasks, createtime, updatetime ) VALUES (?, ?, now(),now())";
				try {
					pstmt2 = conn.prepareStatement(insertSQL);
					for (Contributor contributor : task.getContributorList()) {
						pstmt2.setInt(1, contributor.getContributor());
						pstmt2.setInt(2, task.getCreated_by());
						pstmt2.addBatch();
					}
					pstmt2.executeBatch(); // insert remaining records
					pstmt2.close();
				} catch (Exception e) {
					e.printStackTrace();
				}
			}

		} catch (SQLException e) {
			System.out.println(e.getMessage());
			throw new ApplicationException(Throwables.getStackTraceAsString(e),
					e.getMessage());
		}
	}

	//@DeleteMapping
	@PostMapping(path = "/delete", consumes = MediaType.APPLICATION_JSON_VALUE)
	@CrossOrigin(origins = "*")
	@ResponseStatus(value = HttpStatus.ACCEPTED, reason = "Task Deleted Successfully")
	public int deleteTasks(@RequestBody Task task) {

		
		String deleteSQL= "DELETE FROM task_user WHERE tasks = ?;";
		String deleteComments = "DELETE FROM comments WHERE task_id = ?;";
		PreparedStatement pstmt2 = null;
		PreparedStatement pstmt3 = null;
		try (Connection conn = this.connect();
				PreparedStatement pstmt = conn.prepareStatement(deleteSQL)) {
			pstmt.setInt(1, task.getId());
			pstmt.executeUpdate();
			
			pstmt3 = conn.prepareStatement(deleteComments);
			pstmt3.setInt(1, task.getId());
			pstmt3.executeUpdate();
			
			String deleteSQL2 = "DELETE FROM tasks WHERE id = ?;";
			pstmt2 = conn.prepareStatement(deleteSQL2);
			pstmt2.setInt(1, task.getId());
			pstmt2.executeUpdate();
			
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return task.getId();
	}

	private Connection connect() {
		Connection conn = null;
		try {
			conn = dataSource.getConnection();
		} catch (SQLException e) {
			System.out.println(e.getMessage());
			throw new ApplicationException(Throwables.getStackTraceAsString(e),
					e.getMessage());
		}
		return conn;
	}

}
