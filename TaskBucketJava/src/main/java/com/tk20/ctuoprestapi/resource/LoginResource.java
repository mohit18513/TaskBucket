package main.java.com.tk20.ctuoprestapi.resource;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import javax.sql.DataSource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.google.common.base.Throwables;

import main.java.com.ExceptionHandlers.ApplicationException;
import main.java.com.ExceptionHandlers.BadPasswordError;
import main.java.com.tk20.Entities.User;
import main.java.com.tk20.services.Logger;

@RestController
@RequestMapping(path = "/task-bucket-api/login")
public class LoginResource {

	// @Autowired
	// JDBCTemplateQueryExecutor jDBCTemplateQueryExecutor;
	@Autowired
	Logger logger;
	@Autowired
	DataSource dataSource = null;

	@CrossOrigin(origins = "*")
	@PostMapping(path = "", consumes = MediaType.APPLICATION_JSON_VALUE)
	public User authenticateUsers(@RequestBody User user) {

		String sql = "select * from users where email ='" + user.getEmail() + "';";

		ResultSet userCursor = null;
		try (Connection conn = this.connect(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
			userCursor = pstmt.executeQuery();
			while (userCursor.next()) {
				if (!user.getPwd().equals(userCursor.getString("pwd")))
					throw new BadPasswordError();
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