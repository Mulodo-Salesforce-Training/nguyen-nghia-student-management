/**
 * Created by nguyen.nghia@mulodo.com on 10/25/2017.
 */
public class SM_EmailHelperUtil {
	// Send Mail Method using Template from SF
	public static void sendMailUsingSFTemplate(User user, String templateName) {
		if (user == null) { return; } // skipped if candidate == null
		OrgWideEmailAddress owa = [SELECT Id, DisplayName, Address FROM  OrgWideEmailAddress LIMIT 1];
		EmailTemplate emailTemplate;
		try {
			emailTemplate = [SELECT Id FROM EmailTemplate WHERE Name=: templateName];
		} catch(QueryException e) {
			throw e;
		}
		// select a dummy contact
		Contact c = [select id, Email from Contact where email <> null limit 1];
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); // mail content will be sent
		List<Messaging.SingleEmailMessage>  willRollBackMailList = new List<Messaging.SingleEmailMessage>(); // email in this list will not be sent
		List<Messaging.SingleEmailMessage>  willSendMailList = new List<Messaging.SingleEmailMessage>();

		mail.setToAddresses(new List<String> {user.Email});
		mail.setTargetObjectId(c.Id);
		mail.setTemplateID(emailTemplate.Id);
		mail.setSaveAsActivity(false);
		mail.setOrgWideEmailAddressId(owa.Id);
//		mail.setWhatId(user.Id);
		willRollBackMailList.add(mail);
		sendEmailUsingTemplateAfterRollBack(willRollBackMailList);

	}

	public static void sendMailToStudentUsingSFTemplate(List<Student__c> students, String templateName) {
		if (students == null) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Email will not be sent because of empty student List'));
			return;
		} // skipped if candidate == null
		OrgWideEmailAddress owa = [SELECT Id, DisplayName, Address FROM  OrgWideEmailAddress LIMIT 1];
		EmailTemplate emailTemplate;
		List<Messaging.SingleEmailMessage>  willRollBackMailList = new List<Messaging.SingleEmailMessage>(); // email in this list will not be sent
		List<Messaging.SingleEmailMessage>  willSendMailList = new List<Messaging.SingleEmailMessage>();
		try {
			emailTemplate = [SELECT Id FROM EmailTemplate WHERE Name=: templateName];
		} catch(QueryException e) {
			throw e;
		}
		for(Student__c receiver: students) {
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); // mail content will be sent
			// select a dummy contact
			Contact c = [select id, Email from Contact where email <> null limit 1];
			mail.setToAddresses(new List<String> {receiver.Email__c});
			mail.setTargetObjectId(c.Id);
			mail.setTemplateID(emailTemplate.Id);
			mail.setSaveAsActivity(false);
			mail.setWhatId(receiver.Id); // Id Of Student assign
			mail.setOrgWideEmailAddressId(owa.Id);
			willRollBackMailList.add(mail);
		}

		sendEmailUsingTemplateAfterRollBack(willRollBackMailList);
	}

	private static void sendEmailUsingTemplateAfterRollBack(List<Messaging.SingleEmailMessage> emails) {
		Savepoint sp = Database.setSavepoint();
		Messaging.sendEmail(emails);
		Database.rollback(sp);
		List<Messaging.SingleEmailMessage> willSendMailList = new List<Messaging.SingleEmailMessage>();
		for(Messaging.SingleEmailMessage ml: emails) {
			Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
			emailToSend.setToAddresses(ml.getToAddresses());
			emailToSend.setPlainTextBody(ml.getPlainTextBody());
			emailToSend.setHtmlBody(ml.getHtmlBody());
			emailToSend.setSubject(ml.getSubject());
			willSendMailList.add(emailToSend);
		}
		Messaging.sendEmail(willSendMailList);
	}
}