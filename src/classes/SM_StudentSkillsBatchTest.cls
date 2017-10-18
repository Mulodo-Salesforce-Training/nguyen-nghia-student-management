/**
 * Created by nguyen.nghia@mulodo.com on 10/17/2017.
 */
@isTest
private class SM_StudentSkillsBatchTest {

	@TestSetup
	static void setupData() {
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

		String skillSet = 'Java Basic Knowledge;Redis'; // mock skill set

		for(Integer i = 0; i < 10; i++) {
			mockStudentList.add(new Student__c(
					First_Name__c = 'Nghia_'+ i,
					Last_Name__c = 'Nguyen_'+ i,
					Email__c = 'nguyen.nghia@mulodo.com',
					Skills__c = skillSet
			));
		}

		insert mockStudentList;
	}

	@isTest static void testNewStudentSkillBatch() {
		Test.startTest();
			SM_StudentSkillsBatch skillBatch = new SM_StudentSkillsBatch();
			Database.executeBatch(skillBatch);
		Test.stopTest();

		System.assertEquals(20, [SELECT COUNT() FROM Student_Scoring_Skill__c], 'There should 20 student scoring skill should be insert');
	}

	/** In this test case
	*	We will update an existed student (add new skill)
	*	Expect the scoring skill list will be 21 instead of 20 in the previous test case
	*/
	@isTest static void testExistedStudentSkillBatch() {
		Student__c student = [SELECT Id, Skills__c FROM Student__c WHERE First_Name__c =: 'Nghia_0'];
		student.Skills__c += ';OOP';

		Test.startTest();
			update student;
			SM_StudentSkillsBatch skillBatch = new SM_StudentSkillsBatch();
			Database.executeBatch(skillBatch);
		Test.stopTest();
		System.assertEquals(21, [SELECT COUNT() FROM Student_Scoring_Skill__c], 'There should 21 student scoring skill should be insert');

	}

}