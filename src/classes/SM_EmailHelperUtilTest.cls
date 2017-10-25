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
		Student__c student = new Student__c(
			First_Name__c = 'Test_1',
			Last_Name__c = 'Test_1',
			Email__c = 'nguyen.nghia@mulodo.com'
		);
		insert student;

	}
	/** Test Case: Send to Null Candidate ===> email should not be sent
	*/
	@isTest() static void TestSendMessageErr() {
		User user = [SELECT Id, Email FROM User WHERE FirstName = 'Nghia' LIMIT 1];
		Test.startTest();
		SM_EmailHelperUtil.sendMailUsingSFTemplate(null, null);

		try{
			SM_EmailHelperUtil.sendMailUsingSFTemplate(user, 'Wrong Email Template Name');
		} catch (QueryException e) {
			System.assert(e.getMessage() != null, 'Expect to be able to catch wrong emailTemplate issue');
		}
		Test.stopTest();
		Integer emailInvocations = Limits.getEmailInvocations();
		System.assertEquals(emailInvocations, 0, 'should not send an error email');

	}
	/** Test Case: Send to Correct Candidate ===> expect email should be sent
	*/
	@isTest() static void TestSendMessageWithTemplate() {
		User user = [SELECT Id, Email FROM User WHERE FirstName = 'Nghia' LIMIT 1];
		// test
		Test.startTest();
		SM_EmailHelperUtil.sendMailUsingSFTemplate(user, 'System Status Notification');
		Integer emailInvocation = Limits.getEmailInvocations();
		Test.stopTest();
		System.assertEquals(emailInvocation, 2, 'Should send 2 email turns (1 roll back) after invoke sendMailMethod');
	}

	@isTest() static void TestSendMailToStudentUsingTemplate() {
		Student__c student = [SELECT Id, Email__c FROM Student__c LIMIT 1];
		Test.startTest();
		SM_EmailHelperUtil.sendMailToStudentUsingSFTemplate(new List<Student__c> {student}, 'Student Level Update Notification');
		Integer emailInvocation = Limits.getEmailInvocations();
		Test.stopTest();
		System.assertEquals(emailInvocation, 2 , 'Should send 2 email (1 roll back) after invoke sendMailToStudentUsingSFTemplate Method');
	}

	@isTest() static void TestSendMailToStudentUsingWrongTemplate() {
		Student__c student = [SELECT Id, Email__c FROM Student__c LIMIT 1];
		Test.startTest();
		try {
			SM_EmailHelperUtil.sendMailToStudentUsingSFTemplate(new List<Student__c> {student}, 'Wrong Template Name');
		} catch(QueryException e) {
			System.assert(e.getMessage() != null, 'Should be able to get exception message');
		}

		Integer emailInvocation = Limits.getEmailInvocations();
		Test.stopTest();
		System.assertEquals(emailInvocation, 0 , 'Should not send any emails');
	}

	@isTest() static void TestSendMailToEmptyStudents() {
		Test.startTest();
		SM_EmailHelperUtil.sendMailToStudentUsingSFTemplate(null, 'Wrong Template Name');
		Integer emailInvocation = Limits.getEmailInvocations();
		Test.stopTest();
		System.assertEquals(emailInvocation, 0 , 'Should not send any emails');
	}
}