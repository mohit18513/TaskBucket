package main.java.com.tk20.ctuoprestapi.config;

import javax.sql.DataSource;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.beans.factory.config.ConfigurableBeanFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Scope;
import org.springframework.jdbc.datasource.DriverManagerDataSource;
import org.springframework.stereotype.Component;

@Component
@Configuration
public class ConnectionCreator {
	@Value("${database.IP}")
	private String dataBaseIP;

	@Bean("dataSource")
	@Scope(value = ConfigurableBeanFactory.SCOPE_SINGLETON)
	public DataSource getDataSource() {

		System.out.println("DataBase IP is:" + dataBaseIP);
		DriverManagerDataSource ds = new DriverManagerDataSource();
		ds.setDriverClassName("org.postgresql.Driver");
		ds.setUrl("jdbc:postgresql://" + dataBaseIP + ":5432/task_bucket");
		ds.setUsername("postgres");
		ds.setPassword("postgres");
		System.out.println("connection created successfully");
		return ds;
	}

}