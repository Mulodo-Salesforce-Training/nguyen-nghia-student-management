trigger SM_NewStudentTrigger on Student__c(after insert, after update, before insert, before update) {
	if (!system.isBatch() && !system.isFuture()) {

		if(trigger.isUpdate || trigger.isInsert) {
			SM_StudentSkillsBatch executeBatch = new SM_StudentSkillsBatch();
			Database.executeBatch(executeBatch);
		}
	}


}