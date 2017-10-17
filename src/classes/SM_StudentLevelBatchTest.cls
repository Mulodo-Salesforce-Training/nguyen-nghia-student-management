/**
 * Created by nguyen.nghia@mulodo.com on 10/17/2017.
 */
@isTest
private class SM_StudentLevelBatchTest {
	@TestSetup static void dataFactory() {
		List<Student_Skill__c> listSkill = new List<Student_Skill__c>();
		listSkill.add(new Student_Skill__c(
			Active__c = true,
			Max_Point__c = 600,
			Skill__c = 'OOP'
		));
		listSkill.add(new Student_Skill__c(
			Active__c = true,
			Max_Point__c = 200,
			Skill__c = 'Networking'
		));
		listSkill.add(new Student_Skill__c(
			Active__c = true,
			Max_Point__c = 300,
			Skill__c = 'mySQL'
		));
		listSkill.add(new Student_Skill__c(
			Active__c = true,
			Max_Point__c = 50,
			Skill__c = 'Redis'
		));
		insert listSkill;

		List<Student__c> mockStudentList = new List<Student__c>();
		mockStudentList.add(new Student__c(
			First_Name__c = 'Nghia',
			Last_Name__c = 'Nguyen',
			Email__c = 'nguyen.nghia@mulodo.com',
			Skills__c = 'Networking'
		));
		mockStudentList.add(new Student__c(
				First_Name__c = 'Nghia',
				Last_Name__c = 'Nguyen',
				Email__c = 'nguyen.nghia@mulodo.com',
				Skills__c = 'mySQL'
		));
		mockStudentList.add(new Student__c(
				First_Name__c = 'Nghia',
				Last_Name__c = 'Nguyen',
				Email__c = 'nguyen.nghia@mulodo.com',
				Skills__c = 'Redis'
		));
		mockStudentList.add(new Student__c(
				First_Name__c = 'Nghia',
				Last_Name__c = 'Nguyen',
				Email__c = 'nguyen.nghia@mulodo.com',
				Skills__c = 'OOP'
		));
		insert mockStudentList;

	}

	/** Description: Expect after batch level of
	*/
	@isTest static void TestStudentSkillBatch() {
		Test.startTest();
		SM_StudentLevelBatch levelBatch = new SM_StudentLevelBatch();
		Database.executeBatch(levelBatch);
		Test.stopTest();
		List<Student__c> studentList = [SELECT Skills__c, Level__c, Scores__c FROM Student__c ];
		for(Student__c student: studentList) {
			if (student.Scores__c >= 400) {
				System.assert(student.Level__c == 'Leader', 'Scores >= 400 must be a leader');
			} else if (student.Scores__c >= 300) {
				System.assert(student.Level__c == 'Senior', 'Scores >= 300 must be a senior');
			} else if (student.Scores__c >= 200) {
				System.assert(student.Level__c == 'Junior', 'Scores >= 200 must be a junior');
			} else if (student.Scores__c > 0) {
				System.assert(student.Level__c == 'Fresher', 'Scores > 0 must be a fresher');
			}
		}
	}
}