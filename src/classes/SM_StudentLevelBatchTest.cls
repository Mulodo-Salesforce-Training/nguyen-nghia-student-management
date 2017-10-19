/**
 * Created by nguyen.nghia@mulodo.com on 10/17/2017.
 */
@isTest
private class SM_StudentLevelBatchTest {
	@TestSetup static void dataFactory() {
		List<Student_Skill__c> skillList;
		List<Student__c> mockStudentList;
		List<RecordType> skillRT; // get recordType
		Map<String, Id> skillRTMap = new Map<String, Id>(); // map Name, Id from skillRT
		// get picklist values
		Schema.DescribeFieldResult studentSkills = Student_Skill__c.Skill__c.getDescribe();
		List<Schema.PicklistEntry> studentSkillOption = studentSkills.getPicklistValues();

		skillRT = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'Student_Skill__c' and isActive = true];

		for(RecordType type: skillRT) {
			skillRTMap.put(type.Name, type.Id);
		}

		skillList = new List<Student_Skill__c> {
				new Student_Skill__c(Active__c = true, RecordTypeId = skillRTMap.get('Java'), Skill__c = 'Java Basic Knowledge', Max_Point__c = 100),
				new Student_Skill__c(Active__c = true, RecordTypeId = skillRTMap.get('PHP'), Skill__c = 'OOP', Max_Point__c = 200),
				new Student_Skill__c(Active__c = true, RecordTypeId = skillRTMap.get('Salesforce'), Skill__c = 'Developer Beginner', Max_Point__c = 300),
				new Student_Skill__c(Active__c = true, RecordTypeId = skillRTMap.get('Java'), Skill__c = 'Redis', Max_Point__c = 400)
				};

		insert skillList;
		mockStudentList = new List<Student__c>{
				new Student__c(First_Name__c = 'Nghia', Last_Name__c = 'Nguyen', Email__c = 'nguyen.nghia@mulodo.com', Skills__c = 'Java Basic Knowledge'),
				new Student__c(First_Name__c = 'Nghia', Last_Name__c = 'Nguyen', Email__c = 'nguyen.nghia@mulodo.com', Skills__c = 'OOP'),
				new Student__c(First_Name__c = 'Nghia', Last_Name__c = 'Nguyen', Email__c = 'nguyen.nghia@mulodo.com', Skills__c = 'Developer Beginner'),
				new Student__c(First_Name__c = 'Nghia', Last_Name__c = 'Nguyen', Email__c = 'nguyen.nghia@mulodo.com', Skills__c = 'Redis')
		};
		insert mockStudentList;

	}

	/** Description: Expect after batch level of
	*/
	@isTest static void TestStudentSkillBatch() {
		Test.startTest();
		SM_StudentLevelBatch levelBatch = new SM_StudentLevelBatch();
		Database.executeBatch(levelBatch);
		Test.stopTest();
		List<Student__c> studentList = [SELECT Skills__c, Level__c, Scores__c FROM Student__c LIMIT 4];
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