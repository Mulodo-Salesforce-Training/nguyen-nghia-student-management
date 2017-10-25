/**
 * Created by nguyen.nghia@mulodo.com on 10/19/2017.
 */
public class SM_StudentAvatarCE {
	public transient Blob file {get;set;}
	public String fileName {get;set;} // fileName get from apex:input from Page
	private Student__c selectedStudent;
	private static final Set<String> VALID_IMAGE_EXTENSION = new Set<String> {'jpg', 'jpeg', 'png'};
	private static final Double LIMIT_FILE_SIZE = 2097152 ; // 2 MB ==> bytes

	public SM_StudentAvatarCE(ApexPages.StandardController stdCtrl) {
		this.selectedStudent = (Student__c)stdCtrl.getRecord();
	}

	private Id upload() {
		ContentVersion v = new ContentVersion();
		v.versionData = file;
		v.pathOnClient = fileName;
		insert v;
		return v.Id;
	}

	public void uploadAvatar() {
		List<String> splitFileName = fileName.split('\\.');
		if (!VALID_IMAGE_EXTENSION.contains(splitFileName[splitFileName.size() - 1])) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Extension '+ splitFileName[splitFileName.size() -1] + ' is not a valid type'));
			return;
		}
		Double fileSize = 3 * Math.ceil(EncodingUtil.base64Encode(file).length() /4); // file Size of Base64 ===> UTF-8 Image;


		if (fileSize > LIMIT_FILE_SIZE) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Avatar Limit is 2 MB. Please resize or upload other image that size < 2MB'));
			return;
		}
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