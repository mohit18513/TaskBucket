package main.java.com.ExceptionHandlers;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(value = HttpStatus.FORBIDDEN, reason = "ID not available")
public class InvalidMethodRequestException extends RuntimeException
{

}
