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
			SM_StudentCC.changeSelectedStatus(JSON.serialize(targetIdList), 'Working');
		Test.stopTest();

		Student__c updateStudent = [SELECT Status__c FROM Student__c WHERE Id =: targetIdList[0]];
		System.assert(updateStudent.Status__c == 'Working', 'Student with id : ' + updateStudent.Id + ' should has status is working after update');

	}

	@isTest static void testStudentLevelBatchExecute() {

		Test.startTest();
		SM_StudentCC.studentLevelBatchExecute();
		System.assert(!System.isBatch(), 'Batch is execute after 1 minutes');
//		CronTrigger job = [SELECT ID FROM CronTrigger WHERE CronExpression = 'Student Level And Skill Executed' LIMIT 1];
//		System.debug(job);
//		System.assert(job != null, 'should be able to see this job ');
		try {
			SM_StudentCC.studentLevelBatchExecute(); // execute 2nd time
		} catch (AsyncException e) {
			System.assert(e.getMessage() != null, 'Will error if try to execute 2nd time');
		}
		Test.stopTest();

	}

	@isTest static void testParseStudentFromCSVMethod() {
		String mockImportCSVString = 	'First_Name__c,Last_Name__c,Email__c\n' +
										'Nghia,Nguyen,nguyen.nghia@mulodo.com\n' +
										'Trung,Nguyen,trung.nguyen@mulodo.com';

		String mockInvalidColumnCSVString = 'Wrong_Column_c,Last_Name__c,Email__c\n' +
				'Nghia,Nguyen,nguyen.nghia@mulodo.com\n' +
				'Trung,Nguyen,trung.nguyen@mulodo.com';

		String noHeadCSVString = 'Nghia,Nguyen,nguyen.nghia@mulodo.com\n' +
				'Trung,Nguyen,trung.nguyen@mulodo.com';

		String mockFileName = 'testing.csv';
		Blob mockCSVFile = Blob.valueOf(mockImportCSVString);
		SM_StudentCC studentCustomCtrl = new SM_StudentCC();

		List<Student__c> emptyFileImportList = studentCustomCtrl.parseStudentFromCSV(Blob.valueOf(''), 'emptyFile.csv');
		System.assertEquals(emptyFileImportList, null, 'Should be return nothing if empty file input');

		List<Student__c> invalidFileNameList = studentCustomCtrl.parseStudentFromCSV(mockCSVFile, 'wrongExtension.ext');
		System.assertEquals(invalidFileNameList, null, 'Should be able to prevent wrong extension input');

		List<Student__c> invalidColumnList = studentCustomCtrl.parseStudentFromCSV(Blob.valueOf(mockInvalidColumnCSVString), mockFileName);
		System.assertEquals(invalidColumnList, null, 'Should be able to prevent wrong column when import');

		List<Student__c> noHeadstudentList = studentCustomCtrl.parseStudentFromCSV(Blob.valueOf(noHeadCSVString), 'demo.csv');
		System.assertEquals(noHeadstudentList, null, 'Should be able to prevent no head csv file');

		List<Student__c> studentList = studentCustomCtrl.parseStudentFromCSV(mockCSVFile, 'demo.csv');
		System.assertEquals(studentCustomCtrl.importFieldMap.size(), 3, 'Expect there are 3 fields when import');
		System.assertEquals(studentCustomCtrl.getImportKeySet().size(), 3, 'Expect there are 3 key in set when import');
		System.assertEquals(studentList.size(), 2, 'Expect will have 2 student in list');
		System.assertEquals(studentList[0].First_Name__c, 'Nghia', 'Expect exactly import student');
	}

	@isTest static void testExceptionParseStudentFromCSVMethod() {
		Student__c errorStudent = new Student__c(
			First_Name__c = 'Nghia'
		); // missing email student
		SM_StudentCC studentCustomCtrl = new SM_StudentCC();
		studentCustomCtrl.importStudentList = new List<Student__c> {errorStudent};
		try {
			studentCustomCtrl.importCSV();
		} catch (DMlException e) {
			System.assert(e.getMessage() != null, 'Expect to be able to get the error message');
		}

	}

	@isTest static void testGetSetImportMethod() {
		String mockImportCSVString = 	'First_Name__c,Last_Name__c,Email__c\n' +
				'Import_1, Nguyen,nguyen.nghia@mulodo.com\n' +
				'Import_2, Nguyen,trung.nguyen@mulodo.com';
		String mockFileName = 'testing.csv';

		SM_StudentCC studentCustomCtrl = new SM_StudentCC();

		studentCustomCtrl.importCSVfileName = mockFileName;
		System.assertEquals(studentCustomCtrl.importCSVfileName, 'testing.csv', 'Expect be able to set fileName');

		studentCustomCtrl.importFile = Blob.valueOf(mockImportCSVString);
		System.assert(studentCustomCtrl.importFile.size() > 0, 'Expect to be able to set blob(file content)');

		studentCustomCtrl.setImportStudentList();
		System.assertEquals(studentCustomCtrl.importStudentList.size(), 2, 'Should be able to get 2 imports students');

		Test.startTest();
			studentCustomCtrl.importCSV();
		Test.stopTest();

		List<Student__c> importedStudent = [SELECT Id FROM Student__c WHERE First_Name__c LIKE 'Import_%'];
		System.assertEquals(importedStudent.size() , 2, 'Expect to get 2 imported student from SOQL');

		studentCustomCtrl.cancelImportCSV();
		System.assert(studentCustomCtrl.importFile == null, 'Expect to be able to wipe out importFile content');
		System.assert(studentCustomCtrl.importCSVfileName == null, 'Expect to be able to wipe out importCSVFileName');
		System.assert(studentCustomCtrl.importFileSize == 0, 'Expect fileSize after wipe to be 0');
		System.assert(studentCustomCtrl.importStudentList == null, 'Expect to be able to wipe out import Student List');
	}

	@isTest static void testSetNullInImportMethod() {
		SM_StudentCC studentCustomCtrl = new SM_StudentCC();
		PageReference pageRef = Page.SM_ImportCSVWizardPage;
		Test.setCurrentPage(pageRef);
		/** Test case: null importFile and null importFileName*/
		studentCustomCtrl.setImportStudentList();
		System.assertEquals(ApexPages.getMessages()[0].getSummary(), 'Please choose file before click preview ', 'Expect to be able to get error message');
		System.assert(studentCustomCtrl.importStudentList == null, 'Expect to not set data of import student List');


	}

	@isTest static void testNullFileNameInImportMethod() {
		SM_StudentCC studentCustomCtrl = new SM_StudentCC();
		PageReference pageRef = Page.SM_ImportCSVWizardPage;
		Test.setCurrentPage(pageRef);
		/** Test case: null importFileName*/
		studentCustomCtrl.importFile = Blob.valueOf('demoBlob');
		studentCustomCtrl.setImportStudentList();
		System.assertEquals(ApexPages.getMessages()[0].getSummary(), 'file name should not be blank', 'Expect to be able to get error message');
		System.assert(studentCustomCtrl.importStudentList == null, 'Expect to not set data of import student List');
	}

}