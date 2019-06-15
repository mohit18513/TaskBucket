package main.java.com.ExceptionHandlers;

import java.util.HashSet;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

import main.java.com.tk20.services.SendEmail;

@ResponseStatus( value = HttpStatus.INTERNAL_SERVER_ERROR, reason = "Application Exception" )
public class ApplicationException
    extends RuntimeException
{

    public ApplicationException( String messageString, String Subject )
    {
        HashSet<String> emailIdSet = new HashSet<>();
        emailIdSet.add( "smehta@watermarkinsights.com" );
        SendEmail.send( messageString, emailIdSet, "support@tk20.com", Subject );
    }
}
