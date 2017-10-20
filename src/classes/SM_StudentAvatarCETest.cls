/**
 * Created by nguyen.nghia@mulodo.com on 10/20/2017.
 */
@isTest
private class SM_StudentAvatarCETest {
	@TestSetup static void setupData() {
		Student__c mockStudent = new Student__c(
			First_Name__c = 'Nghia',
			Last_Name__c = 'Nguyen',
			Email__c = 'nguyen.nghia@mulodo.com'
		);
		insert mockStudent;
	}

	@isTest static void studentAvatarCETest() {
		Student__c targetStudent = [SELECT Id, AvatarID__c FROM Student__c LIMIT 1];
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController(targetStudent);
		SM_StudentAvatarCE studentAvatarCE = new SM_StudentAvatarCE(stdCtrl);
		studentAvatarCE.fileName = 'demoAvatar.jpg';
		studentAvatarCE.file = Blob.valueOf('00022331132'); // demo blob
		System.assert(studentAvatarCE.getFile() != null, 'Should be able to get the selectedStudent');
		System.assert(studentAvatarCE.getFileName() == 'demoAvatar.jpg', 'Should be able to get the fileName');
		studentAvatarCE.setFileName('demoAvatar.png');
		System.assert(studentAvatarCE.fileName == 'demoAvatar.png', 'Should be able to rename filename');
		studentAvatarCE.setFile(Blob.valueOf('abcxyz'));
		System.asserT(studentAvatarCE.file.toString() == 'abcxyz', 'Should be able to change file');

		Test.startTest();
			Id idImageUploadFile = studentAvatarCE.upload();
		System.assert(idImageUploadFile != null, 'Should be able to upload file');

			studentAvatarCE.uploadAvatar(); // upload Avatar
		Test.stopTest();
		Student__c updateStudent = [SELECT Id, AvatarID__c FROM Student__c LIMIT 1];
		System.debug(updateStudent);
		System.assert(updateStudent.AvatarID__c != null, 'Should be able to get avatarId after upload avatar');
	}
}