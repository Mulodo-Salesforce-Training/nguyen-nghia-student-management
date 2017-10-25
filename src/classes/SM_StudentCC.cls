/**
 * Created by nguyen.nghia@mulodo.com on 10/12/2017.
 */
global with sharing class SM_StudentCC {
	public Integer TotalRecord {get;set;}
	public List<Student__c> importStudentList {get;set;} // List of student going to import
	public Map<String, Integer> importFieldMap {get;set;} // indexOfColumn{Integer}, sObjectField{String}
	public String importCSVfileName {get;set;}
	public transient Blob importFile {get;set;}
	public Integer importFileSize {get;set;}
	public SM_StudentCC() {
		TotalRecord = [SELECT Count() FROM Student__c]; // init total record to show on visualforce page
	}
	// using in SM_StudentListPage
	@RemoteAction
	global static List<Student__c> queryStudentPagination(Integer pageSize, Integer pageNum) {
		pageNum *= pageSize;
		return [SELECT Id, Name, First_Name__c, Last_Name__c, Status__c FROM Student__c LIMIT :pageSize OFFSET :pageNum];
	}

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

	// method to execute batch in VF Page
	global static void studentLevelBatchExecute() {
		if (System.isBatch()) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'This action has already executed'));
			return;
		}
		try {
			System.scheduleBatch(new SM_StudentLevelBatch(), 'Student Level and Skill Executed',1);
		} catch  (AsyncException e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'This action has already been scheduled. Detail Message: ' + e));
			return;
		}

		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Student Level and Skill will be execute within 1 minute'));
	}

	global Set<String> getImportKeySet() {
		return importFieldMap.keySet();
	}

	global void importCSV() {
		try {
			insert importStudentList;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, importStudentList.size() + ' record(s) has been imported by wizard'));
			cancelImportCSV();
		} catch (DmlException e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Dml Exception', e.getMessage()));
		}
	}

	global void cancelImportCSV() {
		importCSVfileName = null;
		importFileSize = 0;
		importFile = null;
		importStudentList = null;
	}

	global void initImportFieldMap(List<String> titleLine) {
		Set<String> studentFieldSet  = Schema.SObjectType.Student__c.fields.getMap().keySet();
		importFieldMap = new Map<String, Integer>();
		for(Integer i = 0; i < titleLine.size(); i ++) {
//			System.debug(titleLine[i].toLowerCase());
//			System.debug(titleLine[i] == 'phone__c');
			if(studentFieldSet.contains(titleLine[i].toLowerCase().trim())) {
//				System.debug(titleLine[i]);
				importFieldMap.put(titleLine[i].toLowerCase().trim(), i); // add exist fields in field Map
			} else {
//				System.debug('Not found column ' + titleLine[i]);
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Column ' + titleLine[i] + 'is not exist in SObject Student__c'));
				return; // return if has error
			}
		}
	}

	global List<Student__c> parseStudentFromCSV(Blob file, String fileName) {
		List<String> fileNameArray; // split file name by dot
		fileNameArray = fileName.split('\\.');
		if (fileNameArray[fileNameArray.size() - 1] != 'csv') {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'File with extension: ' + fileNameArray[fileNameArray.size() - 1] + 'is not support in this wizard' ));
			return null;
		}
		SM_CSVReaderUtil csvReader = new SM_CSVReaderUtil(file.toString());
		List<String> titleLine;  // read the first line (title line) if has title if not skipped here
		List<String> eachLine; // each line in the body of csv file
		List<Student__c> importStudentList = new List<Student__c>();


		// execute
		titleLine = csvReader.readLine();
		if (titleLine == null || titleLine.isEmpty() || titleLine.size() == 1 && titleLine[0] == '') {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This ' + fileName + 'is Empty. Please double check again'));
			return null; // if first line = null => empty File
		}

		initImportFieldMap(titleLine);
		if (importFieldMap == null || importFieldMap.isEmpty()) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Not found any column definition on this CSV file. Import operation is aborted'));
			return null;
		}
		eachLine = csvReader.readLine();

		while(eachLine != null) {
			sObject addStudent = Schema.getGlobalDescribe().get('Student__c').newSObject();
			for(String key: importFieldMap.keySet()) {
				addStudent.put(key, eachLine[importFieldMap.get(key)]);
			}
			importStudentList.add((Student__c)addStudent);

			eachLine = csvReader.readLine(); // reassign to the next line
		}
		return importStudentList;
	}

	global void setImportStudentList() {
		try {
			importStudentList = parseStudentFromCSV(importFile, importCSVfileName);
		} catch (LimitException e) { // limit exception can't be caught
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
		}

	}
}