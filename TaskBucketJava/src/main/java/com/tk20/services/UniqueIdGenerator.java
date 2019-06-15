package main.java.com.tk20.services;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.Random;

import org.springframework.stereotype.Component;

@Component
public class UniqueIdGenerator {

	public String createUniquePrimarykey() {
		Date date = Calendar.getInstance().getTime();
		DateFormat dateFormat = new SimpleDateFormat("yyyymmddhhmmss");
		int str = new Random().nextInt(5);
		return dateFormat.format(str + "" + date);

	}
}
