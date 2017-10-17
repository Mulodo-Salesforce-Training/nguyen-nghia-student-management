/**
 * Created by nguyen.nghia@mulodo.com on 10/17/2017.
 */
@isTest
private class SM_StudentSkillTriggerTest {

	@IsTest static void testStudentSkillTriggerTest() {
		Student_Skill__c conflictStudentSkill = new Student_Skill__c(
			Active__c = true,
				Skill__c = 'OOP',
				Max_Point__c = 500
		);
		insert conflictStudentSkill;
		Test.startTest();
		try {
			insert new Student_Skill__c(
					Active__c = true,
					Skill__c = 'OOP',
					Max_Point__c = 500);
		} catch(DmlException e) {
			System.assert(e.getMessage().contains('Skill with Skill Name: OOP is already existed'));
		}
		Test.stopTest();

	}

	/** Test case that when have 2 or more conflict Student Skill in inserted simultaneously
	*/
	@isTest static void testInsertDoubleConflict() {
		Student_Skill__c conflictStudentSkill = new Student_Skill__c(
				Active__c = true,
				Skill__c = 'OOP',
				Max_Point__c = 500
		);
		insert conflictStudentSkill;
		Test.startTest();
		List<Student_Skill__c> doubleConflictList = new List<Student_Skill__c>();
		doubleConflictList.add(new Student_Skill__c(
				Active__c = true,
				Skill__c = 'OOP',
				Max_Point__c = 500));
		doubleConflictList.add(new Student_Skill__c(
				Active__c = true,
				Skill__c = 'OOP',
				Max_Point__c = 700));
		try {
			insert doubleConflictList;
		} catch(DmlException e) {
			System.assert(e.getMessage().contains('Skill with Skill Name: OOP is already existed'));
		}
		Test.stopTest();
	}
}