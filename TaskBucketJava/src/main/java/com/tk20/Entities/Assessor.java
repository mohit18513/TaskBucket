package main.java.com.tk20.Entities;

public class Assessor
{

    private String assessorName;

    private String assessorIRN;

    private String assessmentStatus;

    private String assessmentStatusTimeStamp;

    public Assessor()
    {
        super();
    }

    public String getAssessorName()
    {
        return assessorName;
    }

    public void setAssessorName( String assessorName )
    {
        this.assessorName = assessorName;
    }

    public String getAssessorIRN()
    {
        return assessorIRN;
    }

    public void setAssessorIRN( String assessorIRN )
    {
        this.assessorIRN = assessorIRN;
    }

    public String getAssessmentStatus()
    {
        return assessmentStatus;
    }

    public void setAssessmentStatus( String assessmentStatus )
    {
        this.assessmentStatus = assessmentStatus;
    }

    public String getAssessmentStatusTimeStamp()
    {
        return assessmentStatusTimeStamp;
    }

    public void setAssessmentStatusTimeStamp( String assessmentStatusTimeStamp )
    {
        this.assessmentStatusTimeStamp = assessmentStatusTimeStamp;
    }

    public Assessor( String assessorName, String assessorIRN, String assessmentStatus, String assessmentStatusTimeStamp )
    {
        super();
        this.assessorName = assessorName;
        this.assessorIRN = assessorIRN;
        this.assessmentStatus = assessmentStatus;
        this.assessmentStatusTimeStamp = assessmentStatusTimeStamp;
    }

    @Override
    public String toString()
    {

        return String.format( "Assessor [assessorName=%s, assessorIRN=%s, assessmentStatus=%s, assessmentStatusTimeStamp=%s]",
                              assessorName, assessorIRN, assessmentStatus, assessmentStatusTimeStamp );

    }

}
