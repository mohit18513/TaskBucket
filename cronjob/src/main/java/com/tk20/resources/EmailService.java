package main.java.com.tk20.resources;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashSet;

import javax.sql.DataSource;

import main.java.com.tk20.services.SendEmail;

public class EmailService {

	public static void main(String[] args) {
		sendEmail(args[0]);
	}

	public static void sendEmail(String dataBaseIP) {
		String ownerAndContrinutorQuery = "select distinct u.email as email, t.title as title, t.description as description from tasks t, users u where u.id = t.owner and t.due_date = current_date +1 union select distinct u2.email as email, t.title as title, t.description as description from tasks t, users u2, task_user tu where u2.id = tu.owner and tu.tasks = t.id  and t.due_date = current_date +1 union select distinct u3.email as email, t.title as title , t.description as description from tasks t, users u3 where u3.id = t.created_by and t.due_date = current_date + 1;";
		PreparedStatement pstmt3 = null;
		Connection con = null;
		try {
			Class.forName("org.postgresql.Driver");
			con = DriverManager.getConnection("jdbc:postgresql://" + dataBaseIP
					+ ":5432/task_bucket", "postgres", "postgres");
			pstmt3 = con.prepareStatement(ownerAndContrinutorQuery);
			ResultSet ownerAndContrinutorCursor = pstmt3.executeQuery();
			while (ownerAndContrinutorCursor.next()) {
				String emailBody = "The description for the task goes as follows: "
						+ ownerAndContrinutorCursor.getString("description");
				HashSet<String> emailSet = new HashSet<String>();
				emailSet.add(ownerAndContrinutorCursor.getString("email"));
				if (!emailSet.isEmpty())
					SendEmail.send(
							emailBody,
							emailSet,
							"support@taskbucket.in",
							"Reminder: "
									+ ownerAndContrinutorCursor
											.getString("title")
									+ " is due Tomorrow.");
			}
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (ClassNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		if (pstmt3 != null)
			try {
				pstmt3.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

	}

}
