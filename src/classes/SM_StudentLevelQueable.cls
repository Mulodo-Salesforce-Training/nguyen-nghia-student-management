/**
 * Created by nguyen.nghia@mulodo.com on 10/18/2017.
 */
public class SM_StudentLevelQueable implements Queueable{

	public Void execute(System.QueueableContext context) {
		List<Student__c> recordList = [SELECT Scores__c, Level__c FROM Student__c];
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
}