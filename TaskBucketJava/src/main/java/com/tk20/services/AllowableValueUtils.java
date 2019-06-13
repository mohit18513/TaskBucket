package main.java.com.tk20.services;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.HashMap;
import java.util.Map;

public class AllowableValueUtils
{

    static Map<String, String> binderFormMapping = null;

    public static Map<String, String> getValuesMap( Connection con, String listdomainDefinition )
    {
        if ( binderFormMapping != null )
            return binderFormMapping;
        binderFormMapping = new HashMap<String, String>();
        String allowableValueQuery =
            "select tk_internalvalue as externalvalue, tk_externalvalue as internalvalue from tk_allowablevalue where tk_listdomaindefinition in ( select primarykey from tk_listdomaindefinition where tk_name='"
                + listdomainDefinition + "');";
        try (PreparedStatement pstmt = con.prepareStatement( allowableValueQuery );
                        ResultSet allowableValueCursor = pstmt.executeQuery();)
        {
            while ( allowableValueCursor.next() )
            {
                binderFormMapping.put( surroundQuotes( allowableValueCursor.getString( "internalvalue" ) ),
                                       surroundQuotes( allowableValueCursor.getString( "externalvalue" ) ) );
            }
        }
        catch ( Exception e )
        {
            // TODO: handle exception
        }
        return binderFormMapping;
    }

    private static String surroundQuotes( String input )
    {
        return "'" + input + "'";
    }
}
