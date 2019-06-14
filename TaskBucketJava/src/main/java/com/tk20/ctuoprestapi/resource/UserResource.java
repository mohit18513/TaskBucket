package main.java.com.tk20.ctuoprestapi.resource;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashSet;
import java.util.Set;

import javax.sql.DataSource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import main.java.com.tk20.Entities.Task;
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
	public Set<User> getStudentInformation(@RequestParam String user_id) {

		ResultSet userCursor = null;
		Set<User> users = new HashSet<>();
		ResultSet assessorCursor = null;
		try (Connection con = dataSource.getConnection()) {
			String userQuery = "select * from users order;";
			PreparedStatement pstmt = con.prepareStatement(userQuery);
			System.out.println("Query Created..");
			userCursor = pstmt.executeQuery();
			System.out.println("Query Executed..");
			User user = null;
			while (userCursor.next()) {
				user = new User();
				user.setId(userCursor.getString("id"));
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

}
