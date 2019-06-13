package main.java.com.ExceptionHandlers;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(value = HttpStatus.FORBIDDEN, reason = "Could not authenticate this request")
public class ForbiddenException extends RuntimeException {
}