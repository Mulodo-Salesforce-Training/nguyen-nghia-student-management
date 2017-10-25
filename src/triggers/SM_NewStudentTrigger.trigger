trigger SM_NewStudentTrigger on Student__c(after insert, after update) {
	List<Student__c> receiveLevelNotificationList = new List<Student__c>();
	Map<Id, Student__c> oldStudentMap = trigger.isUpdate ? new Map<Id, Student__c>(trigger.old) : null;
		// BEGIN: execute calculate skill batch
		if(!system.isBatch() && !system.isFuture()) {
			SM_StudentSkillsBatch executeBatch = new SM_StudentSkillsBatch();
			Database.executeBatch(executeBatch);
		}
		// END: execute calculate skill batch

		// BEGIN: execute sending Email to Student if level change
		for(Student__c updateStudent: trigger.new) {
			// check if update Level is not null and change ( different from old level)
			if(updateStudent.Level__c !=  null) {
				if(oldStudentMap == null || (oldStudentMap != null && updateStudent.Level__c != oldStudentMap.get(updateStudent.Id).Level__c)) {
					receiveLevelNotificationList.add(updateStudent);
				}
			}
		}
		if (receiveLevelNotificationList.size() > 0 ) {
			try {
				SM_EmailHelperUtil.sendMailToStudentUsingSFTemplate(receiveLevelNotificationList, 'Student Level Update Notification');
			} catch(Exception e) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Some error has occured: ' + e.getMessage()));
			}
		}
		// END: execute sending Email to Student if level change
}