/**
 * Created by nguyen.nghia@mulodo.com on 10/17/2017.
 */
/** Description:
	Trigger to check whether going to insert or update Student Skill is conflict with other existed student skill
*/
trigger SM_StudentSkillTrigger on Student_Skill__c(before insert, before update) {
	String errorTemplate = 'Skill with Skill Name: {0} is already existed'; // errorTemplate for errorMsg
	Map<String, Integer[]> needToCheckSkillMap = new Map<String, Integer[]>(); // map that include skillName and index of studentSkill that has that skillName
	List<Student_Skill__c> conflictSkills; // list of conflict skill

	if (trigger.isInsert || trigger.isUpdate) {
		// store all index of trigger new item in a map to query later
		for(Integer i = 0; i < trigger.new.size(); i++) {
			Student_Skill__c skill = trigger.new[i]; // easier to read
			// if map already contain Skill key ==> add index to the indexList of that key and reassign item of map
			if (needToCheckSkillMap.containsKey(skill.Skill__c)) {
				Integer[] allIndex = needToCheckSkillMap.get(skill.Skill__c);
				allIndex.add(i);
				needToCheckSkillMap.put(skill.Skill__c, allIndex);
			} else {
				needToCheckSkillMap.put(skill.Skill__c, new Integer[] {i});
			}
		}

		conflictSkills = [SELECT Name, Skill__c FROM Student_Skill__c WHERE Skill__c IN :needToCheckSkillMap.keySet()];

		if (conflictSkills.size() > 0) {
			// for each conflict skills from query
			for(Student_Skill__c skill: conflictSkills) {
				// get idList of skillMap
				for(Integer index: needToCheckSkillMap.get(skill.Skill__c)) {
					// add error to client to know which item is conflicted
					String errorMsg = String.format(errorTemplate, new List<String>{skill.Skill__c});
					trigger.new[index].addError(errorMsg);
				}
			}
		}

	}

}