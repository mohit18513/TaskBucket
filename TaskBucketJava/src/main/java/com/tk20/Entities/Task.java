package main.java.com.tk20.Entities;

import java.sql.Timestamp;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@JsonIgnoreProperties(ignoreUnknown = true)
public class Task {

	private String id;

	private String title;

	private String description;

	private String created_by;

	private String Owner;

	private int Status;

	@JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd HH:mm:ss")
	private java.sql.Timestamp last_commented_on;

	@JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd")
	private java.sql.Timestamp due_date;

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

	public int getStatus() {
		return Status;
	}

	public void setStatus(int status) {
		Status = status;
	}

	public Timestamp getLast_commented_on() {
		return last_commented_on;
	}

	public void setLast_commented_on(Timestamp last_commented_on) {
		this.last_commented_on = last_commented_on;
	}

	public Timestamp getDue_date() {
		return due_date;
	}

	public void setDue_date(Timestamp timestamp) {
		this.due_date = timestamp;
	}

}
