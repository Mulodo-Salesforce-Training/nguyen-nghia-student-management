/**
 * Created by nguyen.nghia@mulodo.com on 10/17/2017.
 */
public class SM_StudentLevelBatch implements Database.Batchable<sObject>{
	public System.Iterable<sObject> start(Database.BatchableContext jobId) {
		return [SELECT Scores__c, Level__c FROM Student__c];
	}

	public Void execute(Database.BatchableContext jobId, List<sObject> recordList) {
		List<Student__c> updateList = new List<Student__c>();
		for(Student__c student: (List<Student__c>)recordList) {
			if (student.Scores__c >= 400) {
				student.Level__c = 'Leader';
			} else if (student.Scores__c >= 300) {
				student.Level__c = 'Senior';
			} else if (student.Scores__c >= 200) {
				student.Level__c = 'Junior';
			} else if (student.Scores__c >= 0) {
				student.Level__c = 'Fresher';
			}
			updateList.add(student);
		}
		update updateList;
	}

	public Void finish(Database.BatchableContext jobId) {
		AsyncApexJob job = [SELECT Id, CreatedById, TotalJobItems FROM AsyncApexJob WHERE  Id =: jobId.getJobId()];
		User adminUser = [SELECT Id, Email FROM User WHERE Id =: job.CreatedById];
		SM_EmailHelperUtil.sendMailUsingSFTemplate(adminUser, 'System_Status_Notification');
	}

}