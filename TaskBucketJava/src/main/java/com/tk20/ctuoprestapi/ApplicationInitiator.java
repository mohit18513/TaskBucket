package main.java.com.tk20.ctuoprestapi;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.orm.jpa.HibernateJpaAutoConfiguration;

//@PropertySource(value = "classpath:main/java/resources/application.properties")
@EnableAutoConfiguration(exclude = HibernateJpaAutoConfiguration.class)
@SpringBootApplication( scanBasePackages = { "main.java.com.tk20" } )
public class ApplicationInitiator
{

    public static void main( String[] args )
    {

        SpringApplication.run( ApplicationInitiator.class, args );
        System.out.println( "Application Started" );
    }
}
