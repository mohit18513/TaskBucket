package main.java.com.tk20.Entities;

import java.sql.Date;
import java.sql.Date;
import java.util.List;

public class Task {

	private String id;

	private String title;

	private String description;

	private String created_by;

	private String Owner;

	private String Status;

	private Date last_commented_on;

	private Date due_date;

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public String getCreated_by() {
		return created_by;
	}

	public void setCreated_by(String created_by) {
		this.created_by = created_by;
	}

	public String getOwner() {
		return Owner;
	}

	public void setOwner(String string) {
		Owner = string;
	}

	public String getStatus() {
		return Status;
	}

	public void setStatus(String status) {
		Status = status;
	}

	public Date getLast_commented_on() {
		return last_commented_on;
	}

	public void setLast_commented_on(Date last_commented_on) {
		this.last_commented_on = last_commented_on;
	}

	public Date getDue_date() {
		return due_date;
	}

	public void setDue_date(Date due_date) {
		this.due_date = due_date;
	}

}
