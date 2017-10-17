/**
 * Created by nguyen.nghia@mulodo.com on 10/17/2017.
 */
@isTest
private class SM_NewStudentTriggerTest {
	@TestSetup static void setupData() {
		List<Student_Skill__c> skillList = new List<Student_Skill__c>();
		// get picklist values
		Schema.DescribeFieldResult studentSkills = Student_Skill__c.Skill__c.getDescribe();
		List<Schema.PicklistEntry> studentSkillOption = studentSkills.getPicklistValues();

		for(Schema.PicklistEntry skill: studentSkillOption) {
			skillList.add(new Student_Skill__c(
					Active__c = true,
					Skill__c = skill.getValue(),
					Max_Point__c = 500
			));
		}

		insert skillList;
	}
	@isTest static void testNewStudentTrigger() {
		// get picklist values
		Schema.DescribeFieldResult studentSkills = Student_Skill__c.Skill__c.getDescribe();
		List<Schema.PicklistEntry> studentSkillOption = studentSkills.getPicklistValues();

		String skillSet = studentSkillOption[0].getValue() + ';' + studentSkillOption[1].getValue(); // mock skill set
		System.debug(skillSet);
		Test.startTest();
			List<Student__c> mockStudentList = new List<Student__c>();
			for(Integer i = 0; i < 10; i++) {
				mockStudentList.add(new Student__c(
						First_Name__c = 'Nghia_'+ i,
						Last_Name__c = 'Nguyen_'+ i,
						Email__c = 'nguyen.nghia@mulodo.com',
						Skills__c = skillSet
				));
			}

			insert mockStudentList;
		Test.stopTest();

		System.assertEquals(20, [SELECT COUNT() FROM Student_Scoring_Skill__c], 'There should 20 student scoring skill should be insert');
	}
}