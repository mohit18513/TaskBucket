package main.java.com.tk20.Entities;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@JsonIgnoreProperties(ignoreUnknown = true)
public class Contributor {

	private int contributor;

	public int getContributor() {
		return contributor;
	}

	public void setContributor(int contributor) {
		this.contributor = contributor;
	}

}
