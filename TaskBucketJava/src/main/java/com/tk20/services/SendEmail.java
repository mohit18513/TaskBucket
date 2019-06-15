package main.java.com.tk20.services;

import java.util.HashSet;
import java.util.Properties;

import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

public class SendEmail {
	public static void send(String messageString, HashSet<String> emailIdSet,
			String sender, String subject) {

		// Assuming you are sending email from localhost
		String host = "localhost";

		// Get system properties
		Properties properties = System.getProperties();

		// Setup mail server
		properties.setProperty("mail.smtp.host", host);

		// Get the default Session object.
		Session session = Session.getDefaultInstance(properties);

		try {
			// Create a default MimeMessage object.
			MimeMessage message = new MimeMessage(session);

			// Set From: header field of the header.
			message.setFrom(new InternetAddress(sender));

			// Set To: header field of the header.
			for (String emailId : emailIdSet) {
				message.addRecipient(Message.RecipientType.TO,
						new InternetAddress(emailId));
			}
			// message.addRecipient(Message.RecipientType.TO,
			// new InternetAddress(to1));

			// Set Subject: header field
			message.setSubject(subject);

			// Now set the actual message
			message.setContent(messageString, "text/html");

			// Send message
			Transport.send(message);
			System.out.println("Sent message successfully....");
		} catch (MessagingException mex) {
			mex.printStackTrace();
		}
	}
}