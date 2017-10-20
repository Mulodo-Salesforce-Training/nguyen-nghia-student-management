/**
 * Created by nguyen.nghia@mulodo.com on 10/17/2017.
 */
@isTest
private class SM_NewStudentTriggerTest {
	@TestSetup static void setupData() {
		List<Student_Skill__c> skillList;
		List<Student__c> mockStudentList = new List<Student__c>();
		List<RecordType> skillRT; // get recordType
		Map<String, Id> skillRTMap = new Map<String, Id>(); // map Name, Id from skillRT
		// get picklist values
		Schema.DescribeFieldResult studentSkills = Student_Skill__c.Skill__c.getDescribe();
		List<Schema.PicklistEntry> studentSkillOption = studentSkills.getPicklistValues();

		skillRT = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'Student_Skill__c' and isActive = true];

		for(RecordType type: skillRT) {
			skillRTMap.put(type.Name, type.Id);
		}

		System.debug(studentSkillOption);

//		for(Schema.PicklistEntry skill: studentSkillOption) {
//			skillList.add(new Student_Skill__c(
//					Active__c = true,
//					Skill__c = skill.getLabel(),
//					Max_Point__c = 500
//					RecordType = skillRTMap.get('Java')
//			));
//		}
		skillList = new List<Student_Skill__c> {
				new Student_Skill__c(Active__c = true, RecordTypeId = skillRTMap.get('Java'), Skill__c = 'Java Basic Knowledge', Max_Point__c = 500),
				new Student_Skill__c(Active__c = true, RecordTypeId = skillRTMap.get('PHP'), Skill__c = 'OOP', Max_Point__c = 500),
				new Student_Skill__c(Active__c = true, RecordTypeId = skillRTMap.get('Salesforce'), Skill__c = 'Developer Beginner', Max_Point__c = 500),
				new Student_Skill__c(Active__c = true, RecordTypeId = skillRTMap.get('Java'), Skill__c = 'Redis', Max_Point__c = 500)
				};

		insert skillList;
	}
	@isTest static void testNewStudentTrigger() {
		// get picklist values
		Schema.DescribeFieldResult studentSkills = Student_Skill__c.Skill__c.getDescribe();
		List<Schema.PicklistEntry> studentSkillOption = studentSkills.getPicklistValues();

		String skillSet = 'Java Basic Knowledge;Redis'; // mock skill set
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