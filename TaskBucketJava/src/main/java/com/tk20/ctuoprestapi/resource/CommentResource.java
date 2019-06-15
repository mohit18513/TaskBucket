package main.java.com.tk20.ctuoprestapi.resource;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashSet;

import javax.sql.DataSource;

import main.java.com.ExceptionHandlers.ApplicationException;
import main.java.com.tk20.Entities.Comment;
import main.java.com.tk20.services.SendEmail;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.google.common.base.Throwables;

@RestController
@RequestMapping(path = "/task-bucket-api/tasks/{task_id}/comments")
public class CommentResource {

	@Autowired
	DataSource dataSource = null;

	@CrossOrigin(origins = "*")
	@GetMapping("")
	public ArrayList<Comment> getComments(@PathVariable int task_id) {
		ResultSet commentCursor = null;
		ArrayList<Comment> comments = new ArrayList<>();
		ResultSet assessorCursor = null;
		try (Connection con = dataSource.getConnection()) {
			String commentQuery = "SELECT * FROM comments WHERE task_id=? order by createtime desc;";
			PreparedStatement pstmt = con.prepareStatement(commentQuery);
			pstmt.setInt(1, task_id);
			System.out.println("Get Query Created..");
			commentCursor = pstmt.executeQuery();
			System.out.println("Get Query Executed..");
			Comment comment = null;
			while (commentCursor.next()) {
				comment = new Comment();
				comment.setId(commentCursor.getInt("id"));
				comment.setTask_id(commentCursor.getInt("task_id"));
				comment.setText(commentCursor.getString("text"));
				comment.setCreated_by(commentCursor.getInt("created_by"));
				comment.setCreated_on(commentCursor.getTimestamp("created_on"));
				comment.setCreatetime(commentCursor.getTimestamp("createtime"));
				comments.add(comment);
			}

		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		finally {
			try {
				if (commentCursor != null)
					commentCursor.close();
				if (assessorCursor != null)
					assessorCursor.close();
			} catch (SQLException ex2) {
			}
		}
		return comments;
	}

	@CrossOrigin(origins = "*")
	@PostMapping(path = "", consumes = MediaType.APPLICATION_JSON_VALUE)
	public Comment createComments(@RequestBody Comment comment,
			@PathVariable int task_id) {
		String sql = "INSERT INTO comments (task_id, text, created_by, created_on, createtime ) VALUES ("
				+ task_id
				+ ",'"
				+ comment.getText().replace("'", "\'")
				+ "',"
				+ comment.getCreated_by() + ",now(), now());";
		System.out.println(sql);
		ResultSet commentCursor = null;
		PreparedStatement pstmt2 = null;
		PreparedStatement pstmt3 = null;
		ResultSet ownerAndContrinutorCursor = null;
		ResultSet activeUserCursor = null;
		try (Connection conn = this.connect();
				Statement pstmt = conn.createStatement()) {
			pstmt.execute(sql, Statement.RETURN_GENERATED_KEYS);
			int id = 0;
			try (ResultSet rs = pstmt.getGeneratedKeys()) {
				if (rs.next()) {
					id = rs.getInt(1);
				}
				String updateTaskQuery = "UPDATE tasks SET last_commented_on = now() where id = ?";
				pstmt2 = conn.prepareStatement(updateTaskQuery);
				pstmt2.setInt(1, task_id);
				pstmt2.executeUpdate();

				String commentQuery = "select * from comments where id=" + id
						+ ";";
				pstmt2 = conn.prepareStatement(commentQuery);
				// pstmt.setInt(1, user_id);
				commentCursor = pstmt2.executeQuery();
				comment = new Comment();
				while (commentCursor.next()) {
					comment.setId(commentCursor.getInt("id"));
					comment.setTask_id(commentCursor.getInt("task_id"));
					comment.setText(commentCursor.getString("text"));
					comment.setCreated_by(commentCursor.getInt("created_by"));
					comment.setCreated_on(commentCursor
							.getTimestamp("created_on"));
					comment.setCreatetime(commentCursor
							.getTimestamp("createtime"));
				}

				if (pstmt2 != null)
					pstmt2.close();
				String ownerAndContrinutorQuery = "select distinct u.email as email, t.title as title from tasks t, users u where u.id = t.owner and t.id="
						+ task_id
						+ " union select distinct u2.email as email, t.title as title  from tasks t, users u2, task_user tu where u2.id = tu.owner and tu.tasks = t.id  and t.id="
						+ task_id
						+ "union select distinct u3.email as email, t.title as title from tasks t, users u3 where u3.id = t.created_by and t.id="
						+ task_id + ";";

				String userName = "";
				String userEmail = "";
				String taskTitle = "";
				String activeUserQuery = "select name, email from users where id = ?";

				pstmt2 = conn.prepareStatement(activeUserQuery);
				pstmt2.setInt(1, comment.getCreated_by());
				activeUserCursor = pstmt2.executeQuery();
				activeUserCursor.next();
				userName = activeUserCursor.getString("name");
				userEmail = activeUserCursor.getString("email");

				HashSet<String> emailSet = new HashSet<String>();
				String emailBody = " Below comment has been logged by "
						+ userName
						+ "("
						+ userEmail
						+ ") "
						+ "\n \n at "
						+ new Date()
						+ " Comment :-\n \n <div style='background-color: lightblue; min-width: 800px; min-height:200px;'>"
						+ comment.getText() + "</div>";
				pstmt3 = conn.prepareStatement(ownerAndContrinutorQuery);
				ownerAndContrinutorCursor = pstmt3.executeQuery();
				while (ownerAndContrinutorCursor.next()) {
					taskTitle = ownerAndContrinutorCursor.getString("title");
					emailSet.add(ownerAndContrinutorCursor.getString("email"));
				}

				if (pstmt3 != null)
					pstmt3.close();

				if (!emailSet.isEmpty()) {
					emailSet.remove(userEmail);
					SendEmail.send(emailBody, emailSet,
							"support@taskbucket.in",
							"A new comment has been logged on your task - "
									+ taskTitle);
				}
			} catch (SQLException e) {
				System.out.println(e.getMessage());
				throw new ApplicationException(
						Throwables.getStackTraceAsString(e), e.getMessage());
			} finally {
				if (commentCursor != null)
					try {
						commentCursor.close();
					} catch (SQLException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
			}
		} catch (SQLException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
		return comment;
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
