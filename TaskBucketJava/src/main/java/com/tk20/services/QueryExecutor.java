package main.java.com.tk20.services;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.sql.DataSource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.google.common.base.Joiner;

import main.java.com.tk20.Entities.Assessor;
import main.java.com.tk20.Entities.Binder;
import main.java.com.tk20.Entities.Student;

@Component
public class QueryExecutor {

	@Autowired
	DataSource dataSource = null;

	public Set<Student> getStudentList(String startDate, String endDate) throws SQLException {
		ResultSet personCursor = null;
		Set<Student> studentSet = new HashSet<>();
		ResultSet assessorCursor = null;
		try (Connection con = dataSource.getConnection()) {
			String personAndPortfolioQuery = "select id from users;";
			PreparedStatement pstmt = con.prepareStatement(personAndPortfolioQuery);
			System.out.println("Query Created..");
			personCursor = pstmt.executeQuery();
			System.out.println("Query Executed..");
			while (personCursor.next()) {
				System.out.println(personCursor.getString("id"));
			}

		}

		finally {
			try {
				if (personCursor != null)
					personCursor.close();
				if (assessorCursor != null)
					assessorCursor.close();
			} catch (SQLException ex2) {
			}
		}
		return studentSet;
	}

}