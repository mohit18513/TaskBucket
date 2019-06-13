package main.java.com.tk20.Entities;

import java.util.List;

public class Binder
{

    private String templateTitle;

    private String binderTitle;

    private String binderStatus;

    private List<Assessor> assessors;

    public String getTemplateTitle()
    {
        return templateTitle;
    }

    public void setTemplateTitle( String templateTitle )
    {
        this.templateTitle = templateTitle;
    }

    public String getBinderTitle()
    {
        return binderTitle;
    }

    public void setBinderTitle( String binderTitle )
    {
        this.binderTitle = binderTitle;
    }

    public String getBinderStatus()
    {
        return binderStatus;
    }

    public void setBinderStatus( String binderStatus )
    {
        this.binderStatus = binderStatus;
    }

    public List<Assessor> getAssessors()
    {
        return assessors;
    }

    public void setAssessors( List<Assessor> assessors )
    {
        this.assessors = assessors;
    }

    public Binder( String templateTitle, String binderTitle, String binderStatus, List<Assessor> assessors )
    {
        super();
        this.templateTitle = templateTitle;
        this.binderTitle = binderTitle;
        this.binderStatus = binderStatus;
        this.assessors = assessors;
    }
    
    public Binder()
    {
    }

    @Override
    public String toString()
    {

        return String.format( "Binder [templateTitle=%s, binderTitle=%s, binderStatus=%s, accessors=%s]", templateTitle, binderTitle, binderStatus, assessors.toString() );

    }
}
