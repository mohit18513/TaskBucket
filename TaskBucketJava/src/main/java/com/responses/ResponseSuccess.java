package main.java.com.responses;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(value = HttpStatus.ACCEPTED, reason = "Task Created Successfully")
public class ResponseSuccess extends ResponseEntity{

	public ResponseSuccess(HttpStatus status) {
		super(status);
		// TODO Auto-generated constructor stub
	}


}
