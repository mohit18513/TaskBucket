package main.java.com.tk20.Entities;

import java.sql.Date;
import java.sql.Timestamp;
import java.util.List;

/**
 * @author manishsharma
 *
 */
public class Comment {


	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	private String id;

	private String name;

	private String email;
	
	

	

}
