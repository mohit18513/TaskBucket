package main.java.com.tk20.Entities;

import java.sql.Date;
import java.sql.Timestamp;
import java.util.List;

public class Task {

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

	private String id;

	private String title;

	private String description;

	private Date due_date;

	public Date getDue_date() {
		return due_date;
	}

	public void setDue_date(Date due_date) {
		this.due_date = due_date;
	}

	public Date getCreated_by() {
		return created_by;
	}

	public void setCreated_by(Date created_by) {
		this.created_by = created_by;
	}

	public Integer getOwner() {
		return Owner;
	}

	public void setOwner(Integer owner) {
		Owner = owner;
	}

	public String getStatus() {
		return Status;
	}

	public void setStatus(String status) {
		Status = status;
	}

	public Timestamp getLast_commented_on() {
		return last_commented_on;
	}

	public void setLast_commented_on(Timestamp last_commented_on) {
		this.last_commented_on = last_commented_on;
	}

	private Date created_by;

	private Integer Owner;
	private String Status;

	private Timestamp last_commented_on;

}
