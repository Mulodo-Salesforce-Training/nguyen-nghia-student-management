/**
 * Created by nguyen.nghia@mulodo.com on 10/13/2017.
 */
@isTest
private class SM_StudentCCTest {
	// set up student data for pagination test
	@testSetup static void dataFactory() {
		List<Student__c> mockStudentList = new List<Student__c>();
		for (Integer i = 0; i < 20; i++) {
			mockStudentList.add(new Student__c(
				First_Name__c = 'Nghia_' + i,
				Last_Name__c = 'Nguyen_' + i,
				Email__c = 'nguyen.nghia@mulodo.com'
			));
		}
		insert mockStudentList;
	}

	@isTest static void testConstructor() {
		Test.startTest();
		SM_StudentCC customController = new SM_StudentCC();
		Test.stopTest();
		System.assert(customController.TotalRecord == 20, 'Should return exact number of inserted students');
	}
	// test get student by page size and number of page
	@isTest static void testQueryStudentPagination() {
		Test.startTest();
		List<Student__c> firstTenRow = SM_StudentCC.queryStudentPagination(10, 0);
		Test.stopTest();
		System.assert(firstTenRow.size() == 10 , 'Should return only 10 records');
		System.assert(firstTenRow[0].First_Name__c.equals('Nghia_0'), 'Expect the first Records FirstName is Nghia_0');
		System.assert(firstTenRow[9].First_Name__c.equals('Nghia_9'), 'Expect the last records FirstName is Nghia_9');

	}

	@isTest static void testOutOfBoundException() {
		Test.startTest();
		List<Student__c> thirdTenRow = SM_StudentCC.queryStudentPagination(10, 4);
		List<Student__c> secondTwentyRow = SM_StudentCC.queryStudentPagination(40, 2);
		Test.stopTest();
		System.assert(thirdTenRow.isEmpty(), 'Should return null if outOfBound'); // must be check isEmpty instead of compare with null;
		System.assert(secondTwentyRow.isEmpty(), 'Should return null if outOfBound');
	}

	// test get Status Pick List
	@isTest static void testGetStatusPickList() {
		Test.startTest();
		String returnPickList = SM_StudentCC.getStatusPickList();
		Test.stopTest();
		List<Schema.PicklistEntry> statusPickList = (List<Schema.PicklistEntry>)JSON.deserialize(returnPickList, List<Schema.PicklistEntry>.class);
		System.assert(returnPickList.length() > 0 , 'JSON String Pick List should has more than 1 symbols');
		System.assert(statusPickList.size() > 0 , 'Status Pick List should contain more than 1 pick List');
	}

	@isTest static void testChangeSelectedStatus() {
		List<Id> targetIdList = new List<Id>();
		for(Student__c student: [SELECT Status__c FROM Student__c LIMIT 1]) {
			targetIdList.add(student.Id);
		}

		Test.startTest();
			SM_StudentCC.changeSelectedStatus(targetIdList, 'Working');
		Test.stopTest();

		Student__c updateStudent = [SELECT Status__c FROM Student__c WHERE Id =: targetIdList[0]];
		System.assert(updateStudent.Status__c == 'Working', 'Student with id : ' + updateStudent.Id + ' should has status is working after update');


	}
}