package main.java.com.tk20.services;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import javax.sql.DataSource;

import main.java.com.ExceptionHandlers.ApplicationException;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.google.common.base.Throwables;

@Component
public class Logger
{
    @Autowired
    DataSource dataSource = null;

    private Connection connect()
    {
        Connection conn = null;
        try
        {
            conn = dataSource.getConnection();
        }
        catch ( SQLException e )
        {
            System.out.println( e.getMessage() );
            throw new ApplicationException( Throwables.getStackTraceAsString( e ), e.getMessage() );
        }
        return conn;
    }

    public void log( String requestparamters, String responseobject, String requeststatus )
    {

        String sql = "INSERT INTO requestlogs ( requestparamters, responseobject, requeststatus ) values ( ? ,? ,? );";

        try (Connection conn = this.connect(); PreparedStatement pstmt = conn.prepareStatement( sql ))
        {
            pstmt.setString( 1, requestparamters );
            pstmt.setString( 2, responseobject );
            pstmt.setString( 3, requeststatus );
            pstmt.executeUpdate();
        }
        catch ( SQLException e )
        {
            System.out.println( e.getMessage() );
            throw new ApplicationException( Throwables.getStackTraceAsString( e ), e.getMessage() );
        }
    }
}
