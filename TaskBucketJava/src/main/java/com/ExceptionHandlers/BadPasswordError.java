package main.java.com.ExceptionHandlers;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(value = HttpStatus.FORBIDDEN, reason = "Very Bad Password")
public class BadPasswordError extends RuntimeException
{

}
