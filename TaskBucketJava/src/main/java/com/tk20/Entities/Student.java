package main.java.com.tk20.Entities;

import java.util.List;

public class Student
{

    private String pid;

    private String program;

    private List<Binder> binders;

    public String getPid()
    {
        return pid;
    }

    public void setPid( String pid )
    {
        this.pid = pid;
    }

    public String getProgram()
    {
        return program;
    }

    public void setProgram( String program )
    {
        this.program = program;
    }

    public List<Binder> getBinders()
    {
        return binders;
    }

    @Override
    public boolean equals( Object obj )
    {
        if ( this == obj )
            return true;
        if ( obj == null )
            return false;
        if ( getClass() != obj.getClass() )
            return false;
        Student other = (Student) obj;
        if ( pid == null )
        {
            if ( other.pid != null )
                return false;
        }
        else if ( !pid.equals( other.pid ) )
            return false;
        
        return true;
    }

    public void setBinders( List<Binder> binders )
    {
        this.binders = binders;
    }

    public Student( String pid, String program, List<Binder> binders )
    {
        this.pid = pid;
        this.program = program;
        this.binders = binders;
    }

    public Student()
    {
        super();
    }

    @Override
    public String toString()
    {
        return String.format( "Student [pid=%s, program=%s, binders=%s]", pid, program, binders.toString() );
    }

}
