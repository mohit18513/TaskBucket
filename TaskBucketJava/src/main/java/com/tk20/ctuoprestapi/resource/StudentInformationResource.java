package main.java.com.tk20.ctuoprestapi.resource;

import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Set;

import main.java.com.ExceptionHandlers.ApplicationException;
import main.java.com.ExceptionHandlers.ForbiddenException;
import main.java.com.ExceptionHandlers.InvalidMethodRequestException;
import main.java.com.tk20.Entities.Student;
import main.java.com.tk20.services.Logger;
import main.java.com.tk20.services.QueryExecutor;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import com.google.common.base.Throwables;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

@RestController
@RequestMapping( path = "/getStudentInformation" )
public class StudentInformationResource
{
    @Autowired
    QueryExecutor queryExecutor;

    // @Autowired
    // JDBCTemplateQueryExecutor jDBCTemplateQueryExecutor;
    @Autowired
    Logger logger;

    @PostMapping
    public Set<Student> getStudentInformation( @RequestParam String startDate, @RequestParam String endDate,
                                               @RequestParam String secretMessage )
    {

        // String username = userDetails.getUsername();
        // Collection<? extends GrantedAuthority> authorities = userDetails.getAuthorities();
        // authorities
        // .forEach(System.out::println);

        String requestParamaterString = "startDate=" + startDate + "&endDate=" + endDate + "&secretMessage=" + secretMessage;

        System.out.println( "Request recieved for parameters: " + requestParamaterString );

        ObjectMapper mapperObj = new ObjectMapper();

        // String pattern = "yyyyMMdd";
        // SimpleDateFormat simpleDateFormat = new SimpleDateFormat( pattern );
        //
        // String date = simpleDateFormat.format( new Date() );
        //
        // System.out.println( date );

        if ( !secretMessage.equals( "secretMessage" ) )
            throw new ForbiddenException();

        Set<Student> studentInfo = null;
        try
        {
            studentInfo = queryExecutor.getStudentList( startDate, endDate );
            logger.log( requestParamaterString, mapperObj.writeValueAsString( studentInfo ), "Success" );
        }
        catch ( JsonProcessingException e )
        {
            e.printStackTrace();
            logger.log( requestParamaterString, "UOPRestAPI Error while parsing JSON. Reason:" + e.getMessage(),
                        "Error" );
            throw new ApplicationException( Throwables.getStackTraceAsString( e ), "UOP"
                + "UOPRestAPI Error while parsing JSON. Reason:" + e.getMessage() );
        }
        catch ( SQLException e )
        {
            e.printStackTrace();
            logger.log( requestParamaterString, "UOPRestAPI Error in SQL. Reason:" + e.getMessage(), "Error" );
            throw new ApplicationException( Throwables.getStackTraceAsString( e ), "UOPRestAPI Error in SQL. Reason:"
                + e.getMessage() );
        }

        return studentInfo;
    }

    
    @GetMapping( path = "/test" )
    public Set<Student> handleAllGetRequests2() throws SQLException
    {
        return queryExecutor.getStudentList( "20190505", "20190505" );
    }
    
    @GetMapping( path = "/hello" )
    public String handleAllGetRequests() throws SQLException
    {
        return "hello";
    }

    // @GetMapping( path = "/test2" )
    // public String hello2()
    // {
    // return jDBCTemplateQueryExecutor.getAllUserNames().toString();
    // }
}
