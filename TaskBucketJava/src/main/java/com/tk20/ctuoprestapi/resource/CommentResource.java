package main.java.com.tk20.ctuoprestapi.resource;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

import javax.sql.DataSource;

import main.java.com.ExceptionHandlers.ApplicationException;
import main.java.com.tk20.Entities.Comment;

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
	public Comment createComments(@RequestBody Comment comment, @PathVariable int task_id) {
		String sql = "INSERT INTO comments (task_id  , text, created_by, created_on, createtime ) VALUES (?,?,?,now(), now())";
		ResultSet commentCursor = null;
		PreparedStatement pstmt2 = null;
		try (Connection conn = this.connect(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setInt(1, task_id);
			pstmt.setString(2, comment.getText());
			pstmt.setInt(3, comment.getCreated_by());
			pstmt.executeUpdate();

			String updateTaskQuery = "UPDATE tasks SET last_commented_on = now() where id = ?";
			pstmt2 = conn.prepareStatement(updateTaskQuery);
			pstmt2.setInt(1, task_id);
			pstmt2.executeUpdate();

			String commentQuery = "select * from comments order by createtime desc limit 1;";
			pstmt2 = conn.prepareStatement(commentQuery);
			// pstmt.setInt(1, user_id);
			commentCursor = pstmt2.executeQuery();
			comment = new Comment();
			while (commentCursor.next()) {
				comment.setId(commentCursor.getInt("id"));
				comment.setTask_id(commentCursor.getInt("task_id"));
				comment.setText(commentCursor.getString("text"));
				comment.setCreated_by(commentCursor.getInt("created_by"));
				comment.setCreated_on(commentCursor.getTimestamp("created_on"));
				comment.setCreatetime(commentCursor.getTimestamp("createtime"));
			}

		} catch (SQLException e) {
			System.out.println(e.getMessage());
			throw new ApplicationException(Throwables.getStackTraceAsString(e), e.getMessage());
		} finally {
			if (commentCursor != null)
				try {
					commentCursor.close();
				} catch (SQLException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
		}
		return comment;
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
