package main.java.com.ExceptionHandlers;

import java.util.ArrayList;

import main.java.com.tk20.services.SendEmail;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus( value = HttpStatus.INTERNAL_SERVER_ERROR, reason = "Application Exception" )
public class ApplicationException
    extends RuntimeException
{

    public ApplicationException( String messageString, String Subject )
    {
        ArrayList<String> emailIdList = new ArrayList<>();
        emailIdList.add( "smehta@watermarkinsights.com" );
        SendEmail.send( messageString, emailIdList, "support@tk20.com", Subject );
    }
}
