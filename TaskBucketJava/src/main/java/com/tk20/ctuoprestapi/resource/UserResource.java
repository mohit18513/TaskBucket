package main.java.com.tk20.ctuoprestapi.resource;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashSet;
import java.util.Set;

import javax.sql.DataSource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.CrossOrigin;
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
import main.java.com.tk20.Entities.User;
import main.java.com.tk20.services.Logger;

@RestController
@RequestMapping(path = "/task-bucket-api/users")
public class UserResource {

	// @Autowired
	// JDBCTemplateQueryExecutor jDBCTemplateQueryExecutor;
	@Autowired
	Logger logger;
	@Autowired
	DataSource dataSource = null;

	@CrossOrigin(origins = "*")
	@GetMapping("")
	public Set<User> getStudentInformation() {

		ResultSet userCursor = null;
		Set<User> users = new HashSet<>();
		ResultSet assessorCursor = null;
		try (Connection con = dataSource.getConnection()) {
			String userQuery = "select * from users order by name asc;";
			PreparedStatement pstmt = con.prepareStatement(userQuery);
			System.out.println("Query Created..");
			userCursor = pstmt.executeQuery();
			System.out.println("Query Executed..");
			User user = null;
			while (userCursor.next()) {
				user = new User();
				user.setId(userCursor.getInt("id"));
				user.setName(userCursor.getString("name"));
				user.setEmail(userCursor.getString("email"));
				users.add(user);
			}

		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		finally {
			try {
				if (userCursor != null)
					userCursor.close();
				if (assessorCursor != null)
					assessorCursor.close();
			} catch (SQLException ex2) {
			}
		}
		return users;
	}

	@CrossOrigin(origins = "*")
	@PostMapping(path = "", consumes = MediaType.APPLICATION_JSON_VALUE)
	public User createusers(@RequestBody User user) {

		String sql = "INSERT INTO users (name , email, pwd, createtime ) values(?,?,?,now())";
		ResultSet userCursor = null;
		PreparedStatement pstmt2 = null;

		try (Connection conn = this.connect(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setString(1, user.getName());
			pstmt.setString(2, user.getEmail());
			pstmt.setString(3, user.getPwd());
			pstmt.executeUpdate();
			String userQuery = "select * from users order by createtime desc limit 1;";
			pstmt2 = conn.prepareStatement(userQuery);
			// pstmt.setInt(1, user_id);
			userCursor = pstmt2.executeQuery();
			user = new User();
			while (userCursor.next()) {
				user.setId(userCursor.getInt("id"));
				user.setName(userCursor.getString("name"));
				user.setEmail(userCursor.getString("email"));
				user.setCreatetime(userCursor.getTimestamp("createtime"));
			}

		} catch (SQLException e) {
			System.out.println(e.getMessage());
			throw new ApplicationException(Throwables.getStackTraceAsString(e), e.getMessage());
		}
		return user;
	}

	@CrossOrigin(origins = "*")
	@PutMapping("")
	@ResponseStatus(value = HttpStatus.ACCEPTED, reason = "User Updated Successfully")
	public void updateUser(@RequestBody User user) {

		// if()
		String sql = "UPDATE users SET name = ?, email = ?, pwd = ?, updatetime =now() where id='" + user.getId()
				+ "';";

		try (Connection conn = this.connect(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setString(1, user.getName());
			pstmt.setString(2, user.getEmail());
			pstmt.setString(3, user.getPwd());
			System.out.println(pstmt);
			if (pstmt.executeUpdate() == 0)
				throw new InvalidMethodRequestException();
		} catch (SQLException e) {
			System.out.println(e.getMessage());
			throw new ApplicationException(Throwables.getStackTraceAsString(e), e.getMessage());
		}
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
