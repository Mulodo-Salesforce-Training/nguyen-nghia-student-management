/**
 * Created by nguyen.nghia@mulodo.com on 10/19/2017.
 */
@isTest
private class SM_StudentProfileCETest {
	@TestSetup static void dataSetup() {
		Student__c newStudent = new Student__c(
			First_Name__c = 'Nghia',
			Last_Name__c = 'Nguyen',
			Email__c = 'nguyen.nghia@mulodo.com',
			Street__c = 'Huỳnh Tấn Phát',
			State_Province__c = 'Hồ Chí Minh',
			Country__c = 'Vietnam'
		);
		insert newStudent;
	}
	@isTest static void testStudentProfileCE() {
		Test.setMock(HttpCalloutMock.class, new SM_GlobalHttpMock()); // mock HTTP Callout
		Student__c selectedStudent = [SELECT Id, Street__c, State_Province__c, Country__c, Map_Location__c FROM Student__c LIMIT 1];
		System.assert(selectedStudent.Map_Location__c == null, 'Expect that before go to controller , map_location of selected Student is not available');

		Test.setCurrentPageReference(new PageReference('Page.SM_AvatarCustomActionPage'));
		System.currentPageReference().getParameters().put('id', selectedStudent.Id);

		Test.startTest();
			ApexPages.standardController stdController = new ApexPages.StandardController(selectedStudent);
			SM_StudentProfileCE studentProfileController = new SM_StudentProfileCE(stdController);
			System.assert(studentProfileController.getStudentLocation() != null, 'Still be able to get location data before init');


			studentProfileController.initStudentLocation(); // init action on VF Page

		Test.stopTest();
		System.assert(studentProfileController.studentId == selectedStudent.Id, 'Should be able to get the target student Id');
		System.assert(studentProfileController.targetStudent != null, 'Should be able to get the target student');
		System.assert(studentProfileController.getStudentLocation() != null, 'Able to get location data after init');
		System.assert(studentProfileController.targetStudent.Map_Location__Latitude__s != null, 'Should be able to get location data now');
		System.assert(studentProfileController.getStudentLocation() != null, 'Should be able to get the full address of student');
	}
}