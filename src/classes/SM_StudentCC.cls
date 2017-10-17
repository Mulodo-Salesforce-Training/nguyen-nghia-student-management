/**
 * Created by nguyen.nghia@mulodo.com on 10/12/2017.
 */
global with sharing class SM_StudentCC {
	public Integer TotalRecord {get;set;}
	public SM_StudentCC() {
		TotalRecord = [SELECT Count() FROM Student__c]; // init total record to show on visualforce page
	}
	// using in SM_StudentListPage
	@RemoteAction
	global static List<Student__c> queryStudentPagination(Integer pageSize, Integer pageNum) {
		pageNum *= pageSize;
		return [SELECT Name, First_Name__c, Last_Name__c, Status__c FROM Student__c LIMIT :pageSize OFFSET :pageNum];
	}
//	@RemoteAction
	global static String getStatusPickList() {
		Schema.DescribeFieldResult statusField = Student__c.Status__c.getDescribe();
		List<Schema.PicklistEntry> skillPickList = statusField.getPicklistValues();
		return JSON.serialize(skillPickList);
	}

	@RemoteAction
	global static Boolean changeSelectedStatus(String JSONIdList, String status) {
		List<Id> idList = (List<Id>)JSON.deserialize(JSONIdList, List<Id>.class); // deserialize JSONId List
		List<Student__c> updateStudent = [SELECT Status__c FROM Student__c WHERE Id IN: idList AND Status__c !=: status]; // select list of student with id in {idList} and status not equals to {status} yes
		for(Student__c student: updateStudent) {
			student.Status__c = status;
		}
		Database.update(updateStudent); // update after complete
		return true; // everything ok
	}
}