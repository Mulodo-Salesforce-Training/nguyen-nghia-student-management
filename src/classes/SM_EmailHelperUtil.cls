/**
 * Created by nguyen.nghia@mulodo.com on 10/25/2017.
 */
public class SM_EmailHelperUtil {
	// Send Mail Method using Template from SF
	public static void sendMailUsingSFTemplate(User user, String templateName) {
		if (user == null) { return; } // skipped if candidate == null
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); // mail content will be sent
		OrgWideEmailAddress owa = [SELECT Id, DisplayName, Address FROM  OrgWideEmailAddress LIMIT 1];
		EmailTemplate emailTemplate = [SELECT Id FROM EmailTemplate WHERE Name=: templateName];
		// select a dummy contact
		Contact c = [select id, Email from Contact where email <> null limit 1];

		List<Messaging.SingleEmailMessage>  willRollBackMailList = new List<Messaging.SingleEmailMessage>(); // email in this list will not be sent
		List<Messaging.SingleEmailMessage>  willSendMailList = new List<Messaging.SingleEmailMessage>();

		mail.setToAddresses(new List<String> {user.Email});
		mail.setTargetObjectId(c.Id);
		mail.setTemplateID(emailTemplate.Id);
		mail.setSaveAsActivity(false);
		mail.setOrgWideEmailAddressId(owa.Id);
		mail.setWhatId(user.Id);
		willRollBackMailList.add(mail);
		System.debug(willRollBackMailList);
		Savepoint sp = Database.setSavepoint();
		Messaging.sendEmail(willRollBackMailList);
		Database.rollback(sp);
		// need to roll back to evade from send email to some random contact
		for(Messaging.SingleEmailMessage ml: willRollBackMailList) {
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