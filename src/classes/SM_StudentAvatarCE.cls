/**
 * Created by nguyen.nghia@mulodo.com on 10/19/2017.
 */
public class SM_StudentAvatarCE {
	public Blob file {get;set;}
	public String fileName {get;set;} // fileName get from apex:input from Page
	private Student__c selectedStudent;

	public SM_StudentAvatarCE(ApexPages.StandardController stdCtrl) {
		this.selectedStudent = (Student__c)stdCtrl.getRecord();
	}

	public Id upload() {
		ContentVersion v = new ContentVersion();
		v.versionData = file;
		v.pathOnClient = fileName;
		insert v;
		return v.Id;
	}

	public void uploadAvatar() {
		Id imageId = upload();
		selectedStudent.AvatarID__c	= imageId;
		update selectedStudent;
	}

	public Blob getFile() {
		return this.file;
	}

	public void setFile(Blob file) {
		this.file = file;
	}

	public String getFileName() {
		return this.fileName;
	}

	public void setFileName(String fileName) {
		this.fileName = fileName;
	}
}