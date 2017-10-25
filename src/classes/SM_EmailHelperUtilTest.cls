/**
 * Created by nguyen.nghia@mulodo.com on 10/25/2017.
 */
@isTest
private class SM_EmailHelperUtilTest {
	@TestSetup static void dataFactory() {
		// data factory
		// need to add extra contact because emailSenderTrigger is base on roll back email sending to a random contact
		Contact contact = new Contact(
				Salutation = 'Ms.',
				LastName = 'Nghia',
				Email='test@mulodo.com'
		);
		insert contact;
		User user = new User(
				Email = 'nguyen.nghia@mulodo.com',
				FirstName = 'Nghia'
		);
		insert user;
	}
	/** Test Case: Send to Null Candidate ===> email should not be sent
	*/
	@isTest() static void TestSendMessageErr() {
		Test.startTest();
		SM_EmailHelperUtil.sendMailUsingSFTemplate(null, null);
		Integer emailInvocations = Limits.getEmailInvocations();
		Test.stopTest();
		System.assertEquals(emailInvocations, 0, 'should not send an error email');
	}
	/** Test Case: Send to Correct Candidate ===> expect email should be sent
	*/
	@isTest() static void TestSendMessageWithTemplate() {
		User user = [SELECT Id, Email FROM User WHERE FirstName = 'Nghia' LIMIT 1];

		// test
		Test.startTest();
		SM_EmailHelperUtil.sendMailUsingSFTemplate(user, 'System_Status_Notification');
		Integer emailInvocation = Limits.getEmailInvocations();
		Test.stopTest();
		System.assertEquals(emailInvocation, 2, 'Should send 2 email turns (1 roll back) after invoke sendMailMethod');
	}
}