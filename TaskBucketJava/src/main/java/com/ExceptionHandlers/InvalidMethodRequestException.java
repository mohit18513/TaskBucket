package main.java.com.ExceptionHandlers;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(value = HttpStatus.FORBIDDEN, reason = "Not a valid method")
public class InvalidMethodRequestException extends RuntimeException
{

}
