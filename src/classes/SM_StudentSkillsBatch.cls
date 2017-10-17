/**
 * Created by nguyen.nghia@mulodo.com on 10/17/2017.
 */

/** Description:
Need to find student that not has score of skill that they already had
Execute: insert into Student_Scoring_Skill a record with the target student and target SKill that already find.
Details:
	// STEP 1 : FIND ALL STUDENT AND STUDENT SCORING SKILL THAT HAVE SKILL LIST NOT NULL ===> TARGET UPDATE
	// STEP 2: IN EXECUTE FOR EACH SKILL IN SKILL LIST
	// STEP 2.1: FIND STUDENT_SCORING_SKILL THAT HAS ID EQUALS TO SKILL(GET ID BY USING MAPSKILL)
	// STEP 2.2: IF NOT EXIST YET ===> CREATE A NEW RECORD IN STUDENT_SCORING_SKILL WITH ID = ACCID, AND SKILLID = SKILLID (USING MAPSKILL)
	// STEP 3: WATCH STATUS
*/
public class SM_StudentSkillsBatch implements Database.Batchable<sObject>{

	// QUERY ALL SKILLS LIST FROM STUDENT SKILL
	// MAP EACH SKILL NAME TO EACH SKILL ID
	public Map<String, Student_Skill__c> getAllSkills() {
		Map<String, Student_Skill__c> skillMap =new Map<String, Student_Skill__c>();
		List<Student_Skill__c> allSkills = [SELECT  Id, Skill__c, Max_Point__c FROM Student_Skill__c]; // will not limit because student skill is limited
		// init skillMap when create a batch
		for(Student_Skill__c skill: allSkills) {
			skillMap.put(skill.Skill__c, skill);
		}
		return skillMap;
	}

	public System.Iterable<sObject> start(Database.BatchableContext jobId) {
//		List<Student__c> targetList = [SELECT Id, Skills__c, (SELECT  Student_Scoring_Skill__c.Student_ID__c, Student_Scoring_Skill__c.Student_Skill__c FROM Student_Scoring_Skills__r)  FROM Student__c WHERE Skills__c != NULL]; // query from parent
		return [SELECT Id, Skills__c, (SELECT  Student_Scoring_Skill__c.Student_ID__c, Student_Scoring_Skill__c.Student_Skill__c FROM Student_Scoring_Skills__r)  FROM Student__c WHERE Skills__c != NULL];
	}

	public void execute(Database.BatchableContext jobId, List<sObject> recordList) {
		Map<String, Student_Skill__c> skillMap = getAllSkills(); // skill Map to get skill by skillName

		List<Student_Scoring_Skill__c> insertList = new List<Student_Scoring_Skill__c>(); // scoring list going to be inserted

		for(Student__c student: (List<Student__c>)recordList) {
			List<String> studentSkill = student.Skills__c.split('\\;'); // seperate multiPickList student skill values

			if (studentSkill.size() > 0) {
				// IF STUDENT ALREADY HAS SCORING SKILL IN LIST NEED TO CHECK EXISTED SKILL IN SCORING
				if (student.Student_Scoring_Skills__r.size() > 0 ) {
					Set<String> needToAddSkill = new Set<String>(studentSKill); // Set to control which skill need to be added
					for(String skill: studentSkill) {
						// CHECK IF STUDENT SCORING SKILL == SKILLMAP MEANS THAT SCORING ALREADY EXIST
						for(Student_Scoring_Skill__c studentScoring: Student.Student_Scoring_Skills__r) {
							if (studentScoring.Student_Skill__c == skillMap.get(skill).Id) {
								// REMOVE FROM NEED TO ADD LIST
								needToAddSkill.remove(skill);
							}
						}
					}
					// AFTER REMOVE ALL EXISTED SCORING FROM NEED TO ADD SKILL LIST
					// ADD EACH ITEM TO THE INSERT LIST
					for(String skillWillAdd: needToAddSkill) {
						insertList.add(new Student_Scoring_Skill__c(
							Student_ID__c = student.Id,
							Student_Skill__c = skillMap.get(skillWillAdd).Id,
							Points__c = skillMap.get(skillWillAdd).Max_Point__c
						));
					}

				} else {
					// IF STUDENT NOT HAS SCORING SKILL
					for(String skill: studentSkill) {
						insertList.add(new Student_Scoring_Skill__c(
								Student_ID__c = student.Id,
								Student_Skill__c = skillMap.get(skill).Id,
								Points__c = skillMap.get(skill).Max_Point__c
						));
					}
				}
			}

		}

		insert insertList;
	}

	public Void finish(Database.BatchableContext jobId) {
	}


}